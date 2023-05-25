import Madog
import UIKit

class LevelCompleteViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(
        token: Navigation,
        navigationContext: ForwardBackNavigationContext
    ) -> UIViewController? {
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
        return LevelCompleteViewController(navigationContext: navigationContext, viewModel: viewModel)
    }
}
