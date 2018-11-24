import Madog
import UIKit

let gameIdentifier = "gameIdentifier"

class GameViewControllerProvider: PageFactory, Page {
    private var uuid: UUID?

    // MARK: PageFactory

    static func createPage() -> Page {
        return GameViewControllerProvider()
    }

    // MARK: Page

    func register<Token, Context>(with registry: ViewControllerRegistry<Token, Context>) {
        uuid = registry.add(registryFunction: createViewController(token:context:))
    }

    func unregister<Token, Context>(from registry: ViewControllerRegistry<Token, Context>) {
        guard let uuid = uuid else {
            return
        }

        registry.removeRegistryFunction(uuid: uuid)
    }

    // MARK: Private

    private func createViewController<Token, Context>(token: Token, context: Context) -> UIViewController? {
        guard
            let id = token as? RegistrationLocator,
            id.identifier == gameIdentifier,
            let level = id.level,
            let navigationContext = context as? NavigationContext
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
