import Combine
import Madog
import SceneKit
import SpriteKit
import UIKit

class GameContainerViewController: UIViewController {
    private let navigationContext: Context
    private let inputHandler: GameInputHandler
    private let viewModel: GameViewModel
    private let overlay = OverlayScene()
    private let mainViewController: GameMainViewController
    private let opponentViewContainer = OpponentViewContainer()

    private var cancellables: Set<AnyCancellable> = []

    init(navigationContext: Context, viewModel: GameViewModel, inputHandler: GameInputHandler) {
        self.navigationContext = navigationContext
        self.viewModel = viewModel
        self.inputHandler = inputHandler

        let scene = viewModel.built.scene
        let cameraNode = viewModel.built.initialCameraNode
        mainViewController = GameMainViewController(
            scene: scene,
            cameraNode: cameraNode,
            overlay: overlay
        )

        super.init(nibName: nil, bundle: nil)

        viewModel.delegate = self
        viewModel.built.synthoidEnergy.energyPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] energy in self?.overlay.updateEnergyUI(energy: energy) }
            .store(in: &cancellables)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let sceneView = mainViewController.view as? SCNView else {
            return
        }

        sceneView.delegate = viewModel.built.timeMachine
        viewModel.built.opponentsOperations.delegate = self

        addChild(mainViewController)
        view.addSubview(mainViewController.view)
        mainViewController.didMove(toParent: self)

        mainViewController.view.snp.makeConstraints { make in
            make.center.width.height.equalToSuperview()
        }

        opponentViewContainer.isUserInteractionEnabled = false
        opponentViewContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(opponentViewContainer)

        opponentViewContainer.snp.makeConstraints { make in
            make.right.top.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.2)
        }

        inputHandler.addGestureRecognisers(to: sceneView)
        viewModel.built.playerOperations.preAnimationBlock = {
            self.inputHandler.setGestureRecognisersEnabled(false)
        }

        viewModel.built.playerOperations.postAnimationBlock = {
            self.inputHandler.setGestureRecognisersEnabled(true)
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
}

extension GameContainerViewController: OpponentsOperationsDelegate {
    // MARK: OpponentsOperationsDelegate

    func opponentsOperationsDidAbsorb(_ opponentsOperations: OpponentsOperations) {}

    func opponentsOperationsDidDepleteEnergy(_ opponentsOperations: OpponentsOperations) -> Bool {
        guard viewModel.built.synthoidEnergy.energy > 0 else { return false }
        viewModel.built.synthoidEnergy.adjust(delta: -.treeEnergyValue)
        return true
    }

    func opponentsOperations(_ opponentsOperations: OpponentsOperations, didDetectOpponent cameraNode: SCNNode) {
        DispatchQueue.main.async {
            let scene = self.viewModel.built.scene
            let opponentViewController = SceneViewController(scene: scene, cameraNode: cameraNode)
            self.add(opponentViewController: opponentViewController)

            self.opponentViewContainer.setNeedsLayout()

            UIView.animate(withDuration: .animationDuration) {
                self.opponentViewContainer.layoutIfNeeded()
            }
        }
    }

    func opponentsOperations(_ opponentsOperations: OpponentsOperations, didEndDetectOpponent cameraNode: SCNNode) {
        DispatchQueue.main.async {
            for child in self.children {
                if let opponentViewController = child as? SceneViewController {
                    if opponentViewController.cameraNode == cameraNode {
                        self.remove(opponentViewController: opponentViewController)
                    }
                }
            }

            self.opponentViewContainer.setNeedsLayout()

            UIView.animate(withDuration: .animationDuration) {
                self.opponentViewContainer.layoutIfNeeded()
            }
        }
    }
}

extension GameContainerViewController: GameViewModelDelegate {
    func gameViewModel(_ gameViewModel: GameViewModel, changeCameraNodeTo node: SCNNode) {
        guard let sceneView = mainViewController.view as? SCNView else { return }
        sceneView.pointOfView = node
    }

    func gameViewModel(_ gameViewModel: GameViewModel, levelDidEndWith outcode: LevelScore.Outcome) {
        viewModel.built.timeMachine.stop()
        if let token = viewModel.nextNavigationToken() {
            navigationContext.showLevelSummary(token: token)
        } else {
            navigationContext.showIntro()
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
        let availableVerticalSpace = frame.height - (topBottomSpacing * 2.0)
        let width = frame.width
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
