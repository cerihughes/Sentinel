import Madog
import UIKit

class GameViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(
        token: Navigation,
        navigationContext: ForwardBackNavigationContext
    ) -> UIViewController? {
        guard let localDataSource = services?.localDataSource, case let .game(level) = token else {
            return nil
        }

        let gameScore = localDataSource.localStorage.gameScore ?? .init()
        let worldBuilder = WorldBuilder.createDefault(level: level)
        let viewModel = GameViewModel(
            worldBuilder: worldBuilder,
            gameScore: gameScore
        )
        let inputHandler = SwipeInputHandler(
            playerOperations: viewModel.built.playerOperations,
            nodeMap: viewModel.built.nodeMap,
            nodeManipulator: viewModel.built.nodeManipulator
        )
        return GameContainerViewController(
            navigationContext: navigationContext,
            viewModel: viewModel,
            inputHandler: inputHandler
        )
    }
}
