import Madog
import SceneKit
import UIKit

class LevelSummaryViewController: SceneViewController {
    private let navigationContext: Context
    private let viewModel: LevelSummaryViewModel
    private let tapGestureRecogniser = UITapGestureRecognizer()

    init(navigationContext: Context, viewModel: LevelSummaryViewModel) {
        self.navigationContext = navigationContext
        self.viewModel = viewModel

        super.init(scene: viewModel.built.scene, cameraNode: viewModel.built.initialCameraNode)

        tapGestureRecogniser.addTarget(self, action: #selector(tapGesture(sender:)))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.allowsCameraControl = true

        view.addGestureRecognizer(tapGestureRecogniser)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.startAnimations()

        tapGestureRecogniser.isEnabled = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        viewModel.stopAnimations()

        super.viewDidDisappear(animated)
    }

    // MARK: Tap

    @objc
    private func tapGesture(sender: UIGestureRecognizer) {
        sender.isEnabled = false
        navigationContext.showGame(level: viewModel.worldBuilder.levelConfiguration.level)
    }
}
