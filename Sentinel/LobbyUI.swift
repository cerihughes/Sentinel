import UIKit

let lobbyIdentifier = "lobbyIdentifier"

class LobbyUI: NSObject {
    func register(with registry: ViewControllerRegistry<RegistrationLocator>) {
        _ = registry.add(registryFunction: createViewController(id:context:))
    }

    private func createViewController(id: RegistrationLocator, context: UIContext) -> UIViewController? {
        guard id.identifier == lobbyIdentifier else {
            return nil
        }

        let lobbyViewModel = LobbyViewModel()
        return LobbyViewController(lobbyViewModel: lobbyViewModel)
    }
}
