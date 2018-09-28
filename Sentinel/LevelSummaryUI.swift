import UIKit

let levelSummaryIdentifier = "levelSummaryIdentifier"

class LevelSummaryUI: NSObject {
    func register(with registry: ViewControllerRegistry<RegistrationLocator>) {
        _ = registry.add(registryFunction: createViewController(id:context:))
    }

    private func createViewController(id: RegistrationLocator, context: UI) -> UIViewController? {
        guard
            id.identifier == levelSummaryIdentifier,
            let level = id.level
            else {
                return nil
        }

        let levelConfiguration = MainLevelConfiguration(level: level)
        let nodePositioning = NodePositioning(gridWidth: levelConfiguration.gridWidth,
                                              gridDepth: levelConfiguration.gridDepth,
                                              floorSize: floorSize)
        let nodeFactory = NodeFactory(nodePositioning: nodePositioning,
                                      detectionRadius: levelConfiguration.opponentDetectionRadius * floorSize)

        let world = SpaceWorld(nodeFactory: nodeFactory)
        let viewModel = LevelSummaryViewModel(levelConfiguration: levelConfiguration, nodeFactory: nodeFactory, world: world)
        return LevelSummaryViewController(viewModel: viewModel)
    }
}
