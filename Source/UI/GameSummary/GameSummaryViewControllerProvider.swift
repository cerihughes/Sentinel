import Madog
import UIKit

class GameSummaryViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(token: Navigation, context: Context) -> UIViewController? {
        guard
            let localDataSource,
            case let .gameSummary(level) = token,
            let viewModel = GameSummaryViewModel(
                level: level,
                worldBuilder: WorldBuilder.createDefault(level: level),
                localDataSource: localDataSource
            )
        else {
            return nil
        }
        return GameSummaryViewController(navigationContext: context, viewModel: viewModel)
    }
}
