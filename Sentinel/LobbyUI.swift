import UIKit

let lobbyIdentifier = "lobbyIdentifier"

class LobbyUI: NSObject {
    func register(with registry: ViewControllerRegistry<String>) {
        _ = registry.add(registryFunction: createViewController(id:))
    }

    private func createViewController(id: String) -> UIViewController? {
        guard id == lobbyIdentifier else {
            return nil
        }

        let lobbyViewModel = LobbyViewModel()
        return LobbyViewController(lobbyViewModel: lobbyViewModel)
    }
}
