import SceneKit
import UIKit

class StagingAreaViewController: SceneViewController {
    init(viewModel: StagingAreaViewModel) {
        super.init(scene: viewModel.scene, cameraNode: viewModel.initialCameraNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        guard let sceneView = view as? SCNView else {
            return
        }

        super.viewDidLoad()

        sceneView.allowsCameraControl = true
//        sceneView.debugOptions = [.renderAsWireframe, .showCameras]
        sceneView.showsStatistics = true
    }
}
