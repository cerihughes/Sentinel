import SceneKit
import SpriteKit
import UIKit

class GameMainViewController: SceneViewController {
    let overlay: OverlayScene

    init(scene: SCNScene, cameraNode: SCNNode?, overlay: OverlayScene) {
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

    override func viewDidLayoutSubviews() {
        overlay.size = view.frame.size
        overlay.updateEnergyUI()
    }
}
