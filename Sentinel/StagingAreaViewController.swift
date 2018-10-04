import SceneKit
import UIKit

class StagingAreaViewController: UIViewController {
    let ui: UIContext
    let viewModel: StagingAreaViewModel

    init(ui: UIContext, viewModel: StagingAreaViewModel) {
        self.ui = ui
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = SCNView()
    }

    override func viewDidLoad() {
        guard let sceneView = view as? SCNView else {
            return
        }

        super.viewDidLoad()

        sceneView.scene = viewModel.scene
        sceneView.pointOfView = viewModel.initialCameraNode
        sceneView.allowsCameraControl = true
//        sceneView.debugOptions = [.renderAsWireframe, .showCameras]
        sceneView.showsStatistics = true
    }
}
