import Madog
import UIKit

class GameViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(token: Navigation, context: Context) -> UIViewController? {
        guard let localDataSource, let audioManager, case let .game(level) = token else { return nil }

        let viewModel = GameViewModel(
            worldBuilder: .createDefault(level: level),
            localDataSource: localDataSource,
            audioManager: audioManager
        )
        return GameContainerViewController(navigationContext: context, viewModel: viewModel)
    }
}
