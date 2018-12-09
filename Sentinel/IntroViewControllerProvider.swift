import Madog
import UIKit

fileprivate let introIdentifier = "introIdentifier"

class IntroViewControllerProvider: PageObject {
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

    // Private

    private func createViewController(token: Any, context: Context) -> UIViewController? {
        guard let navigationContext = context as? ForwardBackNavigationContext,
            let id = token as? RegistrationLocator,
            id.identifier == introIdentifier else {
            return nil
        }

        return IntroViewController(navigationContext: navigationContext)
    }
}

extension RegistrationLocator {
    static func createIntroRegistrationLocator() -> RegistrationLocator {
        return RegistrationLocator(identifier: introIdentifier, level: nil)
    }
}
