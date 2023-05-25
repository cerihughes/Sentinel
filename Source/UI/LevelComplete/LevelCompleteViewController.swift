import Madog
import SceneKit
import UIKit

class LevelCompleteViewController: SceneViewController {
    private let navigationContext: Context
    private let viewModel: LevelCompleteViewModel

    init(navigationContext: Context, viewModel: LevelCompleteViewModel) {
        self.navigationContext = navigationContext
        self.viewModel = viewModel
        super.init(scene: viewModel.terrain.scene, cameraNode: viewModel.terrain.initialCameraNode)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.animateCamera()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func tapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let nextToken = viewModel.nextNavigationToken() else { return }
        navigationContext.show(nextToken)
    }
}
