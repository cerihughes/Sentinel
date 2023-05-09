#if DEBUG
import Madog
import UIKit

class StagingAreaViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(
        token: Navigation,
        navigationContext: ForwardBackNavigationContext
    ) -> UIViewController? {
        guard token == .stagingArea else { return nil }
        let viewModel = StagingAreaViewModel()
        return StagingAreaViewController(viewModel: viewModel)
    }
}
#endif
