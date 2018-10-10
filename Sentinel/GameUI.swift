import UIKit

let gameIdentifier = "gameIdentifier"

class GameUI: NSObject, ViewControllerProvider {

    // MARK: ViewControllerProvider

    func register(with registry: ViewControllerRegistry<RegistrationLocator>) {
        _ = registry.add(registryFunction: createViewController(id:context:))
    }

    // MARK: Private

    private func createViewController(id: RegistrationLocator, context: UIContext) -> UIViewController? {
        guard
            id.identifier == gameIdentifier,
            let level = id.level
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
        return GameContainerViewController(ui: context, viewModel: viewModel)
    }
}
