#if DEBUG
import Madog
import UIKit

class MultipleOpponentAbsorbViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(token: Navigation, context: Context) -> UIViewController? {
        guard token == .multipleOpponentAbsorbScenario else { return nil }
        let viewModel = MultipleOpponentAbsorbViewModel()
        return MultipleOpponentAbsorbViewController(viewModel: viewModel)
    }
}
#endif
