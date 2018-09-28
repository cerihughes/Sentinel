import UIKit

let floorSize: Float = 10.0

class UI: NSObject, UIContext {
    private let registry = ViewControllerRegistry<RegistrationLocator>()

    private let navigationController = UINavigationController()

    override init() {
        super.init()

        registry.ui = self

        let lobbyUI = LobbyUI()
        lobbyUI.register(with: registry)

        let levelSummary = LevelSummaryUI()
        levelSummary.register(with: registry)

        let gameUI = GameUI()
        gameUI.register(with: registry)

        let rl = RegistrationLocator(identifier: gameIdentifier, level: 1)
        let initialViewController = registry.createViewController(from: rl)!
        navigationController.pushViewController(initialViewController, animated: false)

        navigationController.isNavigationBarHidden = true
    }

    var initialViewController: UIViewController {
        return navigationController
    }

    // MARK: UIContext

    func navigate(with registrationLocator: RegistrationLocator, animated: Bool) -> Bool {
        if let viewController = registry.createViewController(from: registrationLocator) {
            navigationController.pushViewController(viewController, animated: animated)
        }
        return false
    }

    func leave(viewController: UIViewController, animated: Bool) -> Bool {
        guard let topViewController = navigationController.topViewController else {
            return false
        }

        if topViewController == viewController {
            navigationController.popViewController(animated: animated)
            return true
        }

        return false
    }
}
