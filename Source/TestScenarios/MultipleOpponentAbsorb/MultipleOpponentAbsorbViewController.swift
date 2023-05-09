#if DEBUG
import Madog
import SceneKit
import UIKit

class MultipleOpponentAbsorbViewController: SceneViewController {
    private let viewModel: MultipleOpponentAbsorbViewModel

    init(viewModel: MultipleOpponentAbsorbViewModel) {
        self.viewModel = viewModel
        super.init(scene: viewModel.world.scene, cameraNode: viewModel.initialCameraNode)
    }

    override func viewDidLoad() {
        guard let sceneView = view as? SCNView else {
            return
        }

        super.viewDidLoad()

        sceneView.delegate = viewModel.timeMachine
        sceneView.showsStatistics = true
    }
}
#endif
