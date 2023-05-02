import SceneKit
import UIKit

class GameMainViewController: SceneViewController {
    private let synthoidEnergy: SynthoidEnergy

    init(scene: SCNScene, cameraNode: SCNNode?, overlay: OverlayScene, synthoidEnergy: SynthoidEnergy) {
        self.synthoidEnergy = synthoidEnergy
        super.init(scene: scene, cameraNode: cameraNode, overlay: overlay)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let sceneView = view as? SCNView else {
            return
        }

        sceneView.showsStatistics = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let overlay = overlay as? OverlayScene else {
            return
        }

        overlay.updateEnergyUI(energy: synthoidEnergy.energy)
    }
}
