import SceneKit
import UIKit

class GameMainViewController: SceneViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let sceneView = view as? SCNView else { return }
        sceneView.showsStatistics = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let overlay = overlay as? OverlayScene else { return }
        overlay.refreshEnergyUI()
    }
}
