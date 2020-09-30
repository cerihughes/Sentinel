import Madog
import UIKit

class LobbyViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(token: Navigation, navigationContext: ForwardBackNavigationContext) -> UIViewController? {
        guard
            token == .lobby
        else {
            return nil
        }

        let lobbyViewModel = LobbyViewModel()
        return LobbyViewController(navigationContext: navigationContext, lobbyViewModel: lobbyViewModel)
    }
}
