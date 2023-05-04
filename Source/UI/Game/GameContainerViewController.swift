import Combine
import Madog
import SceneKit
import SpriteKit
import UIKit

class GameContainerViewController: UIViewController {
    private let navigationContext: ForwardBackNavigationContext
    private let inputHandler: GameInputHandler
    private let viewModel: GameViewModel
    private let overlay = OverlayScene()
    private let mainViewController: GameMainViewController
    private let opponentViewContainer = OpponentViewContainer()

    private var cancellables: Set<AnyCancellable> = []

    init(navigationContext: ForwardBackNavigationContext, viewModel: GameViewModel, inputHandler: GameInputHandler) {
        self.navigationContext = navigationContext
        self.viewModel = viewModel
        self.inputHandler = inputHandler

        let scene = viewModel.world.scene
        let cameraNode = viewModel.world.initialCameraNode
        mainViewController = GameMainViewController(
            scene: scene,
            cameraNode: cameraNode,
            overlay: overlay,
            synthoidEnergy: viewModel.synthoidEnergy
        )

        super.init(nibName: nil, bundle: nil)

        viewModel.delegate = self
        viewModel.synthoidEnergy.energyPublisher
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

        sceneView.delegate = viewModel.opponentsOperations
        viewModel.opponentsOperations.delegate = self

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
        viewModel.playerOperations.preAnimationBlock = {
            self.inputHandler.setGestureRecognisersEnabled(false)
        }

        viewModel.playerOperations.postAnimationBlock = {
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

    func opponentsOperations(_: OpponentsOperations, didDetectOpponent cameraNode: SCNNode) {
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

    func opponentsOperationsDidAbsorb(_: OpponentsOperations) {}

    func opponentsOperationsDidDepleteEnergy(_: OpponentsOperations) {
        viewModel.synthoidEnergy.adjust(delta: -treeEnergyValue)
    }

    func opponentsOperations(_: OpponentsOperations, didEndDetectOpponent cameraNode: SCNNode) {
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

extension GameContainerViewController: GameViewModelDelegate {
    func gameViewModel(_ gameViewModel: GameViewModel, changeCameraNodeTo node: SCNNode) {
        guard let sceneView = mainViewController.view as? SCNView else { return }
        sceneView.pointOfView = node
    }

    func gameViewModel(_ gameViewModel: GameViewModel, levelDidEndWith state: GameViewModel.EndState) {
        levelFinished()
    }

    private func levelFinished() {
        viewModel.opponentsOperations.timeMachine.stop()
        _ = navigationContext.navigateBack(animated: true)
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
