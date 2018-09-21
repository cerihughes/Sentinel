import SceneKit
import SpriteKit
import UIKit

class PlayerViewController: OpponentViewController {
    let overlay: SKScene

    init(scene: SCNScene, cameraNode: SCNNode?, overlay: SKScene) {
        self.overlay = overlay

        super.init(scene: scene, cameraNode: cameraNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let sceneView = self.view as? SCNView else {
            return
        }

        sceneView.overlaySKScene = overlay
        sceneView.showsStatistics = true
    }
}
