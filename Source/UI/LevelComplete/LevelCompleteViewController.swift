import Madog
import SceneKit
import UIKit

class LevelCompleteViewController: SceneViewController {
    private let navigationContext: ForwardBackNavigationContext
    private let viewModel: LevelCompleteViewModel

    init(navigationContext: ForwardBackNavigationContext, viewModel: LevelCompleteViewModel) {
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
        navigationContext.navigateForward(token: nextToken, animated: true)
    }
}
