import SceneKit
import SpriteKit
import UIKit

enum Viewer: Int {
    case player = 0, sentinel, sentry1, sentry2, sentry3
}

class GameContainerViewController: UIViewController, GameViewModelDelegate {
    private let viewModel: GameViewModel
    private let mainViewController: GameMainViewController
    private let opponentViewContainer = OpponentViewContainer()

    init(viewModel: GameViewModel) {
        self.viewModel = viewModel

        let scene = viewModel.world.scene
        let cameraNode = viewModel.world.initialCameraNode
        let overlay = viewModel.overlay
        mainViewController = GameMainViewController(scene: scene, cameraNode: cameraNode, overlay: overlay)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let sceneView = mainViewController.view as? SCNView else {
            return
        }

        sceneView.delegate = viewModel
        viewModel.delegate = self

        addChild(mainViewController)
        view.addSubview(mainViewController.view)
        mainViewController.didMove(toParent: self)

        let mainView: UIView = mainViewController.view
        mainView.translatesAutoresizingMaskIntoConstraints = false
        let mainCenterX = mainView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let mainCenterY = mainView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let mainWidth = mainView.widthAnchor.constraint(equalTo: view.widthAnchor)
        let mainHeight = mainView.heightAnchor.constraint(equalTo: view.heightAnchor)

        opponentViewContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(opponentViewContainer)

        let containerRight = opponentViewContainer.rightAnchor.constraint(equalTo: view.rightAnchor)
        let containerTop = opponentViewContainer.topAnchor.constraint(equalTo: view.topAnchor)
        let containerWidth = NSLayoutConstraint(item: opponentViewContainer,
                                                attribute: .width,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .width,
                                                multiplier: 0.2,
                                                constant: 0)
        let containerHeight = opponentViewContainer.heightAnchor.constraint(equalTo: view.heightAnchor)

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
    }

    override func viewWillLayoutSubviews() {
        let size = view.frame.size
        opponentViewContainer.aspectRatio = size.width / size.height
    }

    @objc
    func tapGesture(sender: UIGestureRecognizer) {
        if let sceneView = mainViewController.view as? SCNView, let interaction = interaction(for: sender) {
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

    private func add(opponentViewController: GameOpponentViewController) {
        addChild(opponentViewController)
        opponentViewContainer.addSubview(opponentViewController.view)
        opponentViewController.didMove(toParent: self)
    }

    private func remove(opponentViewController: GameOpponentViewController) {
        opponentViewController.willMove(toParent: nil)
        opponentViewController.view.removeFromSuperview()
        opponentViewController.removeFromParent()
    }

    // MARK: ViewModelDelegate

    func gameViewModel(_: GameViewModel, didChange cameraNode: SCNNode) {
        guard let sceneView = mainViewController.view as? SCNView else {
            return
        }

        sceneView.pointOfView = cameraNode
    }

    func gameViewModel(_: GameViewModel, didDetectOpponent cameraNode: SCNNode) {
        DispatchQueue.main.async {
            let scene = self.viewModel.world.scene
            let opponentViewController = GameOpponentViewController(scene: scene, cameraNode: cameraNode)
            self.add(opponentViewController: opponentViewController)

            self.opponentViewContainer.setNeedsLayout()

            UIView.animate(withDuration: 0.3) {
                self.opponentViewContainer.layoutIfNeeded()
            }
        }
    }

    func gameViewModel(_: GameViewModel, didEndDetectOpponent cameraNode: SCNNode) {
        DispatchQueue.main.async {
            for child in self.children {
                if let opponentViewController = child as? GameOpponentViewController {
                    if opponentViewController.cameraNode == cameraNode {
                        self.remove(opponentViewController: opponentViewController)
                    }
                }
            }

            self.opponentViewContainer.setNeedsLayout()

            UIView.animate(withDuration: 0.3) {
                self.opponentViewContainer.layoutIfNeeded()
            }
        }
    }
}

class OpponentViewContainer: UIView {
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
