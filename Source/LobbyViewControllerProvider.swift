import Madog
import UIKit

private let lobbyIdentifier = "lobbyIdentifier"

class LobbyViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(registrationLocator: RegistrationLocator, navigationContext: ForwardBackNavigationContext) -> UIViewController? {
        guard registrationLocator.identifier == lobbyIdentifier else {
            return nil
        }

        let lobbyViewModel = LobbyViewModel()
        return LobbyViewController(navigationContext: navigationContext, lobbyViewModel: lobbyViewModel)
    }
}

extension RegistrationLocator {
    static func createLobbyRegistrationLocator() -> RegistrationLocator {
        return RegistrationLocator(identifier: lobbyIdentifier, level: nil)
    }
}
