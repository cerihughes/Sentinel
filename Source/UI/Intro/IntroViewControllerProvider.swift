import Madog
import UIKit

class IntroViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(
        token: Navigation,
        navigationContext: ForwardBackNavigationContext
    ) -> UIViewController? {
        guard token == .intro else { return nil }
        let viewModel = IntroViewModel()
        return IntroViewController(navigationContext: navigationContext, viewModel: viewModel)
    }
}
