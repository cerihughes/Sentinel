import Madog
import SceneKit
import UIKit

class LevelSummaryViewController: SceneViewController {
    private let navigationContext: Context
    private let viewModel: LevelSummaryViewModel

    init(navigationContext: Context, viewModel: LevelSummaryViewModel) {
        self.navigationContext = navigationContext
        self.viewModel = viewModel

        super.init(scene: viewModel.terrain.scene, cameraNode: viewModel.terrain.initialCameraNode)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.allowsCameraControl = true

        let tapGestureRecogniser = UITapGestureRecognizer()
        tapGestureRecogniser.addTarget(self, action: #selector(tapGesture(sender:)))
        view.addGestureRecognizer(tapGestureRecogniser)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.startAnimations()
    }

    override func viewDidDisappear(_ animated: Bool) {
        viewModel.stopAnimations()

        super.viewDidDisappear(animated)
    }

    // MARK: Tap

    @objc private func tapGesture(sender: UIGestureRecognizer) {
        sender.isEnabled = false
        navigationContext.show(.game(level: viewModel.level))
    }
}
