import Madog
import UIKit

fileprivate let introIdentifier = "introIdentifier"

class IntroViewControllerProvider: TypedViewControllerProvider {

    // MARK: TypedViewControllerProvider

    override func createViewController(registrationLocator: RegistrationLocator, navigationContext: ForwardBackNavigationContext) -> UIViewController? {
        guard registrationLocator.identifier == introIdentifier else {
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
