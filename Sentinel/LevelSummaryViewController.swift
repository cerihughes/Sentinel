import Madog
import SceneKit
import UIKit

class LevelSummaryViewController: SceneViewController {
    private let forwardNavigationContext: ForwardNavigationContext
    private let viewModel: LevelSummaryViewModel
    private let tapGestureRecogniser = UITapGestureRecognizer()

    init(forwardNavigationContext: ForwardNavigationContext, viewModel: LevelSummaryViewModel) {
        self.forwardNavigationContext = forwardNavigationContext
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

        let rl = RegistrationLocator(identifier: gameIdentifier, level: viewModel.level)
        _ = forwardNavigationContext.navigate(with: rl, from: self, animated: true)
    }
}
