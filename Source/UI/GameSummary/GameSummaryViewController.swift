import Madog
import SceneKit
import UIKit

class GameSummaryViewController: SceneViewController {
    private weak var context: AnyContext<Navigation>?
    private let viewModel: GameSummaryViewModel

    init(context: AnyContext<Navigation>, viewModel: GameSummaryViewModel) {
        self.context = context
        self.viewModel = viewModel
        super.init(scene: viewModel.scene, cameraNode: viewModel.cameraNode)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.animateCamera()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func tapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let nextToken = viewModel.nextNavigationToken() else { return }
        context?.show(nextToken)
    }
}
