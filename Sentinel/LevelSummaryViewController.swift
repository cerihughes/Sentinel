import SceneKit
import UIKit

class LevelSummaryViewController: SceneViewController {
    private let ui: UIContext
    private let viewModel: LevelSummaryViewModel
    private let tapGestureRecogniser = UITapGestureRecognizer()

    init(ui: UIContext, viewModel: LevelSummaryViewModel) {
        self.ui = ui
        self.viewModel = viewModel

        super.init(scene: viewModel.world.scene, cameraNode: viewModel.world.initialCameraNode)

        tapGestureRecogniser.addTarget(self, action: #selector(tapGesture(sender:)))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addGestureRecognizer(tapGestureRecogniser)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tapGestureRecogniser.isEnabled = true
    }

    // MARK: Tap

    @objc
    private func tapGesture(sender: UIGestureRecognizer) {
        sender.isEnabled = false

        let rl = RegistrationLocator(identifier: gameIdentifier, level: viewModel.level)
        _ = ui.navigate(with: rl, animated: true)
    }
}
