import Madog
import UIKit

class GameViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(token: Navigation, context: AnyContext<Navigation>) -> UIViewController? {
        guard let localDataSource, let audioManager, case let .game(level) = token else { return nil }

        let viewModel = GameViewModel(
            level: level,
            worldBuilder: .createDefault(level: level),
            localDataSource: localDataSource,
            audioManager: audioManager
        )
        return GameContainerViewController(context: context, viewModel: viewModel)
    }
}
