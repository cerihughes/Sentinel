import Madog
import UIKit

class IntroViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(
        token: Navigation,
        navigationContext: ForwardBackNavigationContext
    ) -> UIViewController? {
        guard let audioManager, token == .intro else { return nil }
        let viewModel = IntroViewModel(audioManager: audioManager)
        return IntroViewController(navigationContext: navigationContext, viewModel: viewModel)
    }
}
