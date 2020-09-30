import Madog
import SceneKit
import UIKit

class LevelSummaryViewController: SceneViewController {
    private let navigationContext: ForwardBackNavigationContext
    private let viewModel: LevelSummaryViewModel
    private let tapGestureRecogniser = UITapGestureRecognizer()

    init(navigationContext: ForwardBackNavigationContext, viewModel: LevelSummaryViewModel) {
        self.navigationContext = navigationContext
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

        viewModel.startAnimations()

        tapGestureRecogniser.isEnabled = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        viewModel.stopAnimations()

        super.viewDidDisappear(animated)
    }

    // MARK: Tap

    @objc
    private func tapGesture(sender: UIGestureRecognizer) {
        sender.isEnabled = false

        let token = Navigation.game(level: viewModel.level)
        _ = navigationContext.navigateForward(token: token, animated: true)
    }
}
