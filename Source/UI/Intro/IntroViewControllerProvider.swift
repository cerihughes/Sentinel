import Madog
import UIKit

class IntroViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(token: Navigation, context: AnyContext<Navigation>) -> UIViewController? {
        guard let audioManager, token == .intro, let viewModel = IntroViewModel(audioManager: audioManager) else {
            return nil
        }
        return IntroViewController(context: context, viewModel: viewModel)
    }
}
