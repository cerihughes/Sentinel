import Madog
import UIKit

let lobbyIdentifier = "lobbyIdentifier"

class LobbyViewControllerProvider: PageFactory, Page {
    private var uuid: UUID?

    // MARK: PageFactory

    static func createPage() -> Page {
        return LobbyViewControllerProvider()
    }

    // MARK: Page

    func register<Token, Context>(with registry: ViewControllerRegistry<Token, Context>) {
        uuid = registry.add(registryFunction: createViewController(token:context:))
    }

    func unregister<Token, Context>(from registry: ViewControllerRegistry<Token, Context>) {
        guard let uuid = uuid else {
            return
        }

        registry.removeRegistryFunction(uuid: uuid)
    }

    // MARK: Private

    private func createViewController<Token, Context>(token: Token, context: Context) -> UIViewController? {
        guard
            let id = token as? RegistrationLocator,
            id.identifier == lobbyIdentifier,
            let forwardNavigationContext = context as? ForwardNavigationContext else {
            return nil
        }

        let lobbyViewModel = LobbyViewModel()
        return LobbyViewController(forwardNavigationContext: forwardNavigationContext, lobbyViewModel: lobbyViewModel)
    }
}
