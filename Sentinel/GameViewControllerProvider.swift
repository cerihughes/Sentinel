import Madog
import UIKit

fileprivate let gameIdentifier = "gameIdentifier"

class GameViewControllerProvider: PageObject {
    private var uuid: UUID?

    // MARK: PageObject

    override func register(with registry: ViewControllerRegistry) {
        uuid = registry.add(registryFunction: createViewController(token:context:))
    }

    override func unregister(from registry: ViewControllerRegistry) {
        guard let uuid = uuid else {
            return
        }

        registry.removeRegistryFunction(uuid: uuid)
    }

    // MARK: Private

    private func createViewController(token: Any, context: Context) -> UIViewController? {
        guard
            let id = token as? RegistrationLocator,
            id.identifier == gameIdentifier,
            let level = id.level,
            let navigationContext = context as? ForwardBackNavigationContext
            else {
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
