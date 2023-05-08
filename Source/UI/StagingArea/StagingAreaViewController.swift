import SceneKit
import UIKit

class StagingAreaViewController: SceneViewController {
    private let viewModel: StagingAreaViewModel

    init(viewModel: StagingAreaViewModel) {
        self.viewModel = viewModel
        super.init(scene: viewModel.world.scene, cameraNode: viewModel.initialCameraNode)
    }

    override func viewDidLoad() {
        guard let sceneView = view as? SCNView else {
            return
        }

        super.viewDidLoad()

        sceneView.delegate = viewModel.opponentsOperations
        sceneView.allowsCameraControl = true
//        sceneView.debugOptions = [.renderAsWireframe, .showCameras]
        sceneView.showsStatistics = true
    }
}
