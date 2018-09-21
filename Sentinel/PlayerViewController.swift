import SceneKit
import UIKit

class PlayerViewController: OpponentViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let sceneView = self.view as? SCNView else {
            return
        }

        sceneView.showsStatistics = true
    }
}
