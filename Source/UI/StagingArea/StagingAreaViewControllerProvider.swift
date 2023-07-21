#if DEBUG
import Madog
import UIKit

class StagingAreaViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(token: Navigation, context: AnyContext<Navigation>) -> UIViewController? {
        guard token == .stagingArea else { return nil }
        let viewModel = StagingAreaViewModel()
        return StagingAreaViewController(viewModel: viewModel)
    }
}
#endif
