import Madog
import UIKit

class LevelSummaryViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(token: Navigation, context: Context) -> UIViewController? {
        guard case let .levelSummary(level) = token else { return nil }
        let worldBuilder = WorldBuilder.createDefault(level: level)
        let viewModel = LevelSummaryViewModel(worldBuilder: worldBuilder)
        return LevelSummaryViewController(navigationContext: context, viewModel: viewModel)
    }
}
