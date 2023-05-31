import Madog
import SceneKit
import UIKit

class IntroViewController: SceneViewController {
    private let navigationContext: Context
    private let viewModel: IntroViewModel

    init(navigationContext: Context, viewModel: IntroViewModel) {
        self.navigationContext = navigationContext
        self.viewModel = viewModel
        super.init(scene: viewModel.scene, cameraNode: viewModel.cameraNode)
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
        navigationContext.show(.lobby)
    }
}
