import SceneKit
import SpriteKit
import UIKit

class GameContainerViewController: UIViewController, LeafViewController, PlayerViewModelDelegate, OpponentsViewModelDelegate {
    private let ui: UIContext
    private let inputViewModel: SwipeInputHandler
    private let viewModel: GameViewModel
    private let mainViewController: GameMainViewController
    private let opponentViewContainer = OpponentViewContainer()

    var completionData: Bool = false

    init(ui: UIContext, viewModel: GameViewModel) {
        self.ui = ui
        self.viewModel = viewModel
        self.inputViewModel = SwipeInputHandler(playerViewModel: viewModel.playerViewModel,
                                                  opponentsViewModel: viewModel.opponentsViewModel,
                                                  nodeManipulator: viewModel.terrainViewModel.nodeManipulator)

        let scene = viewModel.world.scene
        let cameraNode = viewModel.world.initialCameraNode
        let overlay = viewModel.playerViewModel.overlay
        self.mainViewController = GameMainViewController(scene: scene, cameraNode: cameraNode, overlay: overlay)

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

        sceneView.delegate = viewModel.opponentsViewModel
        viewModel.playerViewModel.delegate = self
        viewModel.opponentsViewModel.delegate = self

        addChild(mainViewController)
        view.addSubview(mainViewController.view)
        mainViewController.didMove(toParent: self)

        let mainView: UIView = mainViewController.view
        mainView.translatesAutoresizingMaskIntoConstraints = false
        let mainCenterX = mainView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let mainCenterY = mainView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let mainWidth = mainView.widthAnchor.constraint(equalTo: view.widthAnchor)
        let mainHeight = mainView.heightAnchor.constraint(equalTo: view.heightAnchor)

        opponentViewContainer.isUserInteractionEnabled = false
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

        inputViewModel.addGestureRecognisers(to: sceneView)
        viewModel.playerViewModel.preAnimationBlock = {
            self.inputViewModel.disableGestureRecognisers()
        }

        viewModel.playerViewModel.postAnimationBlock = {
            self.inputViewModel.enableGestureRecognisers()
        }
    }

    override func viewWillLayoutSubviews() {
        let size = view.frame.size
        opponentViewContainer.aspectRatio = size.width / size.height
    }

    private func add(opponentViewController: SceneViewController) {
        addChild(opponentViewController)
        opponentViewContainer.addSubview(opponentViewController.view)
        opponentViewController.didMove(toParent: self)
    }

    private func remove(opponentViewController: SceneViewController) {
        opponentViewController.willMove(toParent: nil)
        opponentViewController.view.removeFromSuperview()
        opponentViewController.removeFromParent()
    }

    // MARK: PlayerViewModelDelegate

    func playerViewModel(_: PlayerViewModel, didChange cameraNode: SCNNode) {
        guard let sceneView = mainViewController.view as? SCNView else {
            return
        }

        sceneView.pointOfView = cameraNode
    }

    func playerViewModel(_: PlayerViewModel, levelDidEndWith state: GameEndState) {
        completionData = state == .victory
        DispatchQueue.main.async {
            self.viewModel.opponentsViewModel.timeMachine.stop()
            _ = self.ui.leave(viewController: self, animated: true)
        }
    }

    // MARK: OpponentsViewModelDelegate

    func opponentsViewModel(_: OpponentsViewModel, didDetectOpponent cameraNode: SCNNode) {
        DispatchQueue.main.async {
            let scene = self.viewModel.world.scene
            let opponentViewController = SceneViewController(scene: scene, cameraNode: cameraNode)
            self.add(opponentViewController: opponentViewController)

            self.opponentViewContainer.setNeedsLayout()

            UIView.animate(withDuration: 0.3) {
                self.opponentViewContainer.layoutIfNeeded()
            }
        }
    }

    func opponentsViewModelDidDepleteEnergy(_: OpponentsViewModel) {
        viewModel.playerViewModel.adjustEnergy(delta: -treeEnergyValue)
    }

    func opponentsViewModel(_: OpponentsViewModel, didEndDetectOpponent cameraNode: SCNNode) {
        DispatchQueue.main.async {
            for child in self.children {
                if let opponentViewController = child as? SceneViewController {
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
