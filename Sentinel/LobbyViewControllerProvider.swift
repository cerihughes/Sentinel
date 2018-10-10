import UIKit

let lobbyIdentifier = "lobbyIdentifier"

class LobbyViewControllerProvider: NSObject, ViewControllerProvider {

    // MARK: ViewControllerProvider

    func register(with registry: ViewControllerRegistry<RegistrationLocator>) {
        _ = registry.add(registryFunction: createViewController(id:context:))
    }

    // MARK: Private

    private func createViewController(id: RegistrationLocator, context: UIContext) -> UIViewController? {
        guard id.identifier == lobbyIdentifier else {
            return nil
        }

        let lobbyViewModel = LobbyViewModel()
        return LobbyViewController(ui: context, lobbyViewModel: lobbyViewModel)
    }
}