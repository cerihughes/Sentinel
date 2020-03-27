import Madog
import UIKit

private let gameIdentifier = "gameIdentifier"

class GameViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(registrationLocator: RegistrationLocator, navigationContext: ForwardBackNavigationContext) -> UIViewController? {
        guard registrationLocator.identifier == gameIdentifier,
            let level = registrationLocator.level else {
            return nil
        }

        let levelConfiguration = MainLevelConfiguration(level: level)
        let nodePositioning = NodePositioning(gridWidth: levelConfiguration.gridWidth,
                                              gridDepth: levelConfiguration.gridDepth,
                                              floorSize: floorSize)

        let materialFactory = MainMaterialFactory(level: levelConfiguration.level)
        let nodeFactory = NodeFactory(nodePositioning: nodePositioning,
                                      detectionRadius: levelConfiguration.opponentDetectionRadius * floorSize,
                                      materialFactory: materialFactory)

        let world = SpaceWorld(nodeFactory: nodeFactory)
        let viewModel = GameViewModel(levelConfiguration: levelConfiguration, nodeFactory: nodeFactory, world: world)
        let inputHandler = SwipeInputHandler(playerOperations: viewModel.playerOperations,
                                             opponentsOperations: viewModel.opponentsOperations,
                                             nodeManipulator: viewModel.terrainOperations.nodeManipulator)
        return GameContainerViewController(navigationContext: navigationContext, viewModel: viewModel, inputHandler: inputHandler)
    }
}

extension RegistrationLocator {
    static func createGameRegistrationLocator(level: Int) -> RegistrationLocator {
        return RegistrationLocator(identifier: gameIdentifier, level: level)
    }
}
