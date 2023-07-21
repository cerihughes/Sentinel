import Madog
import SceneKit
import UIKit

class IntroViewController: SceneViewController {
    private weak var context: AnyContext<Navigation>?
    private let viewModel: IntroViewModel

    init(context: AnyContext<Navigation>, viewModel: IntroViewModel) {
        self.context = context
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
        context?.show(.lobby)
    }
}
