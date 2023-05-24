import Madog
import SceneKit
import UIKit

class IntroViewController: SceneViewController {
    private let navigationContext: ForwardBackNavigationContext
    private let viewModel: IntroViewModel

    init(navigationContext: ForwardBackNavigationContext, viewModel: IntroViewModel) {
        self.navigationContext = navigationContext
        self.viewModel = viewModel
        super.init(scene: viewModel.terrain.scene, cameraNode: viewModel.terrain.initialCameraNode)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.startAudio()
        viewModel.animate()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func tapped(_ gestureRecognizer: UITapGestureRecognizer) {
        viewModel.stopAudio()
        navigationContext.showLobby()
    }
}
