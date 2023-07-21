import Madog
import UIKit

class GameSummaryViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(token: Navigation, context: AnyContext<Navigation>) -> UIViewController? {
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
        return GameSummaryViewController(context: context, viewModel: viewModel)
    }
}
