import Madog
import UIKit

class GameViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(
        token: Navigation,
        navigationContext: ForwardBackNavigationContext
    ) -> UIViewController? {
        guard
            let localDataSource = services?.localDataSource,
            case let .game(level) = token
        else {
            return nil
        }

        let gameScore = localDataSource.localStorage.gameScore ?? .init()

        let levelConfiguration = MainLevelConfiguration(level: level)
        let nodePositioning = NodePositioning(gridWidth: levelConfiguration.gridWidth,
                                              gridDepth: levelConfiguration.gridDepth,
                                              floorSize: floorSize)

        let materialFactory = MainMaterialFactory(level: levelConfiguration.level)
        let nodeFactory = NodeFactory(nodePositioning: nodePositioning,
                                      detectionRadius: levelConfiguration.opponentDetectionRadius * floorSize,
                                      materialFactory: materialFactory)

        let world = SpaceWorld(nodeFactory: nodeFactory)
        let viewModel = GameViewModel(
            levelConfiguration: levelConfiguration,
            gameScore: gameScore,
            nodeFactory: nodeFactory,
            world: world
        )
        let inputHandler = SwipeInputHandler(playerOperations: viewModel.playerOperations,
                                             opponentsOperations: viewModel.opponentsOperations,
                                             nodeManipulator: viewModel.terrainOperations.nodeManipulator)
        return GameContainerViewController(
            navigationContext: navigationContext,
            viewModel: viewModel,
            inputHandler: inputHandler
        )
    }
}
