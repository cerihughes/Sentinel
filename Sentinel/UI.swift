import UIKit

let floorSize: Float = 10.0

class UI: NSObject {
    private let registry = ViewControllerRegistry<RegistrationLocator>()

    override init() {
        super.init()

        registry.ui = self

        let lobbyUI = LobbyUI()
        lobbyUI.register(with: registry)

        let levelSummary = LevelSummaryUI()
        levelSummary.register(with: registry)

        let gameUI = GameUI()
        gameUI.register(with: registry)
    }

    var initialViewController: UIViewController {
        let rl = RegistrationLocator(identifier: gameIdentifier, level: 1)
        return registry.createViewController(from: rl)!
    }
}
