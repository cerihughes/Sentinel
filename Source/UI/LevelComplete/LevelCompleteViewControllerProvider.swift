import Madog
import UIKit

class LevelCompleteViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(token: Navigation, context: Context) -> UIViewController? {
        guard case let .levelComplete(level) = token else { return nil }
        let worldBuilder = WorldBuilder.createDefault(level: level)
        let viewModel = LevelCompleteViewModel(level: level, worldBuilder: worldBuilder)
        return LevelCompleteViewController(navigationContext: context, viewModel: viewModel)
    }
}
