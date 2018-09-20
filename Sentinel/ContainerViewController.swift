import SceneKit
import UIKit

enum Viewer: Int {
    case player = 0, sentinel, sentry1, sentry2, sentry3
}

class ContainerViewController: UIViewController, ViewModelDelegate {
    private let viewModel: ViewModel
    private let oppositionContainer = OppositionViewContainer()
    private let playerViewController: PlayerViewController

    init(viewModel: ViewModel) {
        self.viewModel = viewModel

        let scene = viewModel.world.playerScene
        let cameraNode = viewModel.world.initialCameraNode
        playerViewController = PlayerViewController(scene: scene, cameraNode: cameraNode)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let sceneView = playerViewController.view as? SCNView else {
            return
        }

        sceneView.delegate = viewModel
        viewModel.delegate = self

        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)

        let mainView: UIView = playerViewController.view
        mainView.translatesAutoresizingMaskIntoConstraints = false
        let mainCenterX = mainView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let mainCenterY = mainView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let mainWidth = mainView.widthAnchor.constraint(equalTo: view.widthAnchor)
        let mainHeight = mainView.heightAnchor.constraint(equalTo: view.heightAnchor)

        oppositionContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(oppositionContainer)

        let containerRight = oppositionContainer.rightAnchor.constraint(equalTo: view.rightAnchor)
        let containerTop = oppositionContainer.topAnchor.constraint(equalTo: view.topAnchor)
        let containerWidth = NSLayoutConstraint(item: oppositionContainer,
                                                attribute: .width,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .width,
                                                multiplier: 0.2,
                                                constant: 0)
        let containerHeight = oppositionContainer.heightAnchor.constraint(equalTo: view.heightAnchor)

        NSLayoutConstraint.activate([mainCenterX, mainCenterY, mainWidth, mainHeight,
                                     containerRight, containerTop, containerWidth, containerHeight])

        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(tapGesture(sender:)))
        sceneView.addGestureRecognizer(tapRecogniser)

        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(tapGesture(sender:)))
        longPressRecogniser.isEnabled = false
        sceneView.addGestureRecognizer(longPressRecogniser)

        let panRecogniser = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
        panRecogniser.isEnabled = false
        sceneView.addGestureRecognizer(panRecogniser)

        viewModel.preAnimationBlock = {
            tapRecogniser.isEnabled = false
            longPressRecogniser.isEnabled = false
            panRecogniser.isEnabled = false
        }

        viewModel.postAnimationBlock = {
            tapRecogniser.isEnabled = true
            longPressRecogniser.isEnabled = true
            panRecogniser.isEnabled = true
        }

        let scene = viewModel.world.opponentScene
        let cameraNode = viewModel.cameraNode(for: .sentinel)
        let sentinelViewController = OpponentViewController(scene: scene, cameraNode: cameraNode)
        add(oppositionController: sentinelViewController)

        let rawValueOffset = Viewer.sentry1.rawValue
        for i in 0 ..< viewModel.levelConfiguration.sentryCount {
            if let viewer = Viewer(rawValue: i + rawValueOffset) {
                let cameraNode = viewModel.cameraNode(for: viewer)
                let sentryViewController = OpponentViewController(scene: scene, cameraNode: cameraNode)
                add(oppositionController: sentryViewController)
            }
        }
    }

    override func viewWillLayoutSubviews() {
        let size = view.frame.size
        oppositionContainer.aspectRatio = size.width / size.height
    }

    @objc
    func tapGesture(sender: UIGestureRecognizer) {
        if let sceneView = playerViewController.view as? SCNView, let interaction = interaction(for: sender) {
            let point = sender.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(point, options: [:])
            if viewModel.process(interaction: interaction, hitTestResults: hitTestResults) {
                // Toggle the state to "complete" the gesture
                sender.isEnabled = false
                sender.isEnabled = true
            }
        }
    }

    @objc
    func panGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view!)
        let deltaX = Float(translation.x)
        viewModel.processPan(by: deltaX, finished: sender.state == .ended)
    }

    private func interaction(for sender: UIGestureRecognizer) -> UserInteraction? {
        if sender.isKind(of: UITapGestureRecognizer.self) {
            return .tap
        }

        if sender.isKind(of: UILongPressGestureRecognizer.self) {
            return .longPress
        }

        return nil
    }

    private func add(oppositionController: UIViewController) {
        addChild(oppositionController)
        oppositionContainer.addSubview(oppositionController.view)
        oppositionController.didMove(toParent: self)
    }

    private func remove(oppositionController: UIViewController) {
        oppositionController.willMove(toParent: nil)
        oppositionController.view.removeFromSuperview()
        oppositionController.removeFromParent()
    }

    // MARK: ViewModelDelegate

    func viewModel(_: ViewModel, didChange cameraNode: SCNNode) {
        guard let sceneView = playerViewController.view as? SCNView else {
            return
        }

        sceneView.pointOfView = cameraNode
    }
}

class OppositionViewContainer: UIView {
    private let maxViews: Int = 4
    private let topBottomSpacing: CGFloat = 20.0

    var aspectRatio: CGFloat = 4.0 / 3.0 {
        didSet {
            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        let availableVerticalSpace = self.frame.height - (topBottomSpacing * 2.0)
        let width = self.frame.width
        let height = width / aspectRatio
        let usedVerticalSpace = height * CGFloat(maxViews)
        let freeVerticalSpace = availableVerticalSpace - usedVerticalSpace
        let spacing = freeVerticalSpace / CGFloat(maxViews - 1)
        let heightPlusSpacing = height + spacing
        let x: CGFloat = 0.0
        var y = topBottomSpacing
        for subview in subviews {
            subview.frame = CGRect(x: x, y: y, width: width, height: height)
            y += heightPlusSpacing
        }
    }
}
