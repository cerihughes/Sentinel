import Combine
import Madog
import SceneKit
import SpriteKit
import UIKit

class GameContainerViewController: UIViewController {
    private weak var context: AnyContext<Navigation>?
    private let viewModel: GameViewModel
    private let overlay = OverlayScene()
    private let mainViewController: GameMainViewController
    private let opponentViewContainer = OpponentViewContainer()

    private var cancellables: Set<AnyCancellable> = []

    init(context: AnyContext<Navigation>, viewModel: GameViewModel) {
        self.context = context
        self.viewModel = viewModel

        mainViewController = GameMainViewController(
            scene: viewModel.scene,
            cameraNode: viewModel.cameraNode,
            overlay: overlay
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

        sceneView.delegate = viewModel.timeMachine
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

        sceneView.addGestureRecognisers(from: viewModel.inputHandler)
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
        guard viewModel.synthoidEnergy.energy > 0 else { return false }
        viewModel.synthoidEnergy.adjust(delta: -.treeEnergyValue)
        return true
    }

    func opponentsOperations(_ opponentsOperations: OpponentsOperations, didDetectOpponent cameraNode: SCNNode) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let opponentViewController = SceneViewController(scene: self.viewModel.scene, cameraNode: cameraNode)
            self.add(opponentViewController: opponentViewController)

            self.opponentViewContainer.setNeedsLayout()

            UIView.animate(withDuration: .animationDuration) { [weak self] in
                self?.opponentViewContainer.layoutIfNeeded()
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
        viewModel.timeMachine.stop()
        if let token = viewModel.nextNavigationToken() {
            context?.change(to: .basic(), tokenData: .single(token))
        } else {
            context?.show(.intro)
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
