import Madog
import UIKit

class LevelCompleteViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(token: Navigation, context: Context) -> UIViewController? {
        guard
            let localDataSource,
            case let .levelComplete(level) = token,
            let viewModel = LevelCompleteViewModel(
                level: level,
                worldBuilder: WorldBuilder.createDefault(level: level),
                localDataSource: localDataSource
            )
        else {
            return nil
        }
        return LevelCompleteViewController(navigationContext: context, viewModel: viewModel)
    }
}
