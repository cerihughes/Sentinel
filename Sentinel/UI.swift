import UIKit

class UI: NSObject {
    private let registry = ViewControllerRegistry<String>()

    override init() {
        super.init()

        let lobbyUI = LobbyUI()
        lobbyUI.register(with: registry)

        let levelSummary = LevelSummaryUI()
        levelSummary.register(with: registry)

        let gameUI = GameUI()
        gameUI.register(with: registry)
    }

    var initialViewController: UIViewController {
        return registry.createViewController(from: gameIdentifier)!
    }
}
