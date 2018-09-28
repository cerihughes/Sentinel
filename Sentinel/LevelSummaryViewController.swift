import SceneKit
import UIKit

class LevelSummaryViewController: SceneViewController {
    private let viewModel: LevelSummaryViewModel

    init(viewModel: LevelSummaryViewModel) {
        self.viewModel = viewModel

        super.init(scene: viewModel.world.scene, cameraNode: viewModel.world.initialCameraNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
