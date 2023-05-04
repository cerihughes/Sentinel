import Madog
import UIKit

class LevelSummaryViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(
        token: Navigation,
        navigationContext: ForwardBackNavigationContext
    ) -> UIViewController? {
        guard case let .levelSummary(level) = token else { return nil }
        let worldBuilder = WorldBuilder.createDefault(level: level)
        let viewModel = LevelSummaryViewModel(worldBuilder: worldBuilder)
        return LevelSummaryViewController(navigationContext: navigationContext, viewModel: viewModel)
    }
}
