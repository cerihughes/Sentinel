#if DEBUG
import SceneKit
import UIKit

class StagingAreaViewController: SceneViewController {
    private let viewModel: StagingAreaViewModel

    init(viewModel: StagingAreaViewModel) {
        self.viewModel = viewModel
        super.init(scene: viewModel.built.scene, cameraNode: viewModel.built.initialCameraNode)
    }

    override func viewDidLoad() {
        guard let sceneView = view as? SCNView else {
            return
        }

        super.viewDidLoad()

        sceneView.delegate = viewModel.built.timeMachine
        sceneView.allowsCameraControl = true
//        sceneView.debugOptions = [.renderAsWireframe, .showCameras]
        sceneView.showsStatistics = true
    }
}
#endif
