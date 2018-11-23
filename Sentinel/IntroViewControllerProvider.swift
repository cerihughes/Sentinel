import Madog
import UIKit

let introIdentifier = "introIdentifier"

class IntroViewControllerProvider: PageFactory, Page {
    private var uuid: UUID?

    // MARK: PageFactory

    static func createPage() -> Page {
        return IntroViewControllerProvider()
    }

    // MARK: Page

    func register<Token, Context>(with registry: ViewControllerRegistry<Token, Context>) {
        uuid = registry.add(globalRegistryFunction: createViewController(context:))
    }

    func unregister<Token, Context>(from registry: ViewControllerRegistry<Token, Context>) {
        guard let uuid = uuid else {
            return
        }

        registry.removeGlobalRegistryFunction(uuid: uuid)
    }

    // Private

    private func createViewController<Context>(context: Context) -> UIViewController? {
        guard let forwardNavigationContext = context as? ForwardNavigationContext else {
            return nil
        }

        return IntroViewController(forwardNavigationContext: forwardNavigationContext)
    }
}
