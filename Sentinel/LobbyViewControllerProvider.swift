import Madog
import UIKit

fileprivate let lobbyIdentifier = "lobbyIdentifier"

class LobbyViewControllerProvider: PageObject {
    private var uuid: UUID?

    // MARK: PageObject

    override func register(with registry: ViewControllerRegistry) {
        uuid = registry.add(registryFunction: createViewController(token:context:))
    }

    override func unregister(from registry: ViewControllerRegistry) {
        guard let uuid = uuid else {
            return
        }

        registry.removeRegistryFunction(uuid: uuid)
    }

    // MARK: Private

    private func createViewController(token: Any, context: Context) -> UIViewController? {
        guard
            let id = token as? RegistrationLocator,
            id.identifier == lobbyIdentifier,
            let navigationContext = context as? ForwardBackNavigationContext else {
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
