import Madog
import UIKit

class LobbyViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(token: Navigation, context: AnyContext<Navigation>) -> UIViewController? {
        guard token == .lobby else { return nil }
        let lobbyViewModel = LobbyViewModel()
        return LobbyViewController(context: context, lobbyViewModel: lobbyViewModel)
    }
}
