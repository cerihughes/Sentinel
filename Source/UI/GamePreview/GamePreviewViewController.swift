import Madog
import SceneKit
import UIKit

class GamePreviewViewController: SceneViewController {
    private weak var context: AnyContext<Navigation>?
    private let viewModel: GamePreviewViewModel

    init(context: AnyContext<Navigation>, viewModel: GamePreviewViewModel) {
        self.context = context
        self.viewModel = viewModel

        super.init(scene: viewModel.scene, cameraNode: viewModel.cameraNode)
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
        context?.show(.game(level: viewModel.level))
    }
}
