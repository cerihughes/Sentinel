import Madog
import UIKit

class IntroViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(token: Navigation, navigationContext: ForwardBackNavigationContext) -> UIViewController? {
        guard
            token == .intro
        else {
            return nil
        }

        return IntroViewController(navigationContext: navigationContext)
    }
}
