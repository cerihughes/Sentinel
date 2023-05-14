import Madog
import UIKit

class GameViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(token: Navigation, context: Context) -> UIViewController? {
        guard let localDataSource, case let .game(level) = token else { return nil }

        let worldBuilder = WorldBuilder.createDefault(level: level)
        let viewModel = GameViewModel(
            worldBuilder: worldBuilder,
            localDataSource: localDataSource
        )
        let inputHandler = SwipeInputHandler(
            playerOperations: viewModel.built.playerOperations,
            nodeMap: viewModel.built.nodeMap,
            nodeManipulator: viewModel.built.nodeManipulator
        )
        return GameContainerViewController(
            navigationContext: context,
            viewModel: viewModel,
            inputHandler: inputHandler
        )
    }
}
