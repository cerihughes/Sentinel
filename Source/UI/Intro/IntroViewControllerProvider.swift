import Madog
import UIKit

class IntroViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(token: Navigation, context: Context) -> UIViewController? {
        guard let audioManager, token == .intro, let viewModel = IntroViewModel(audioManager: audioManager) else {
            return nil
        }
        return IntroViewController(navigationContext: context, viewModel: viewModel)
    }
}
