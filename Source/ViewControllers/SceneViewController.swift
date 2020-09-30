import SceneKit
import SpriteKit
import UIKit

/**
 A VC that does some of the full-screen SceneKit / SpriteKit setup.
 */
class SceneViewController: UIViewController {
    let scene: SCNScene
    let cameraNode: SCNNode?
    let overlay: SKScene?

    init(scene: SCNScene, cameraNode: SCNNode?, overlay: SKScene? = nil) {
        self.scene = scene
        self.cameraNode = cameraNode
        self.overlay = overlay

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = SCNView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let sceneView = view as? SCNView else {
            return
        }

        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.black
        sceneView.pointOfView = cameraNode
        sceneView.overlaySKScene = overlay
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let overlay = overlay else {
            return
        }

        overlay.size = view.frame.size
    }
}
