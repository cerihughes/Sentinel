import SceneKit
import UIKit

class OpponentViewController: UIViewController {
    let scene: SCNScene
    let cameraNode: SCNNode?

    init(scene: SCNScene, cameraNode: SCNNode?) {
        self.scene = scene
        self.cameraNode = cameraNode

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = SCNView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let sceneView = self.view as? SCNView else {
            return
        }

        sceneView.scene = scene
        sceneView.backgroundColor = UIColor(white: 0.7, alpha: 1.0)
        sceneView.pointOfView = cameraNode
    }
}
