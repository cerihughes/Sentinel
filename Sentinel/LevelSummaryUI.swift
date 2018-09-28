import UIKit

let levelSummaryIdentifier = "levelSummaryIdentifier"

class LevelSummaryUI: NSObject {
    func register(with registry: ViewControllerRegistry<String>) {
        _ = registry.add(registryFunction: createViewController(id:))
    }

    private func createViewController(id: String) -> UIViewController? {
        guard id == levelSummaryIdentifier else {
            return nil
        }

        let floorSize: Float = 10.0
        let levelConfiguration = MainLevelConfiguration(level: 40)
        let nodePositioning = NodePositioning(gridWidth: levelConfiguration.gridWidth,
                                              gridDepth: levelConfiguration.gridDepth,
                                              floorSize: 10.0)
        let nodeFactory = NodeFactory(nodePositioning: nodePositioning,
                                      detectionRadius: levelConfiguration.opponentDetectionRadius * floorSize)

        let world = SpaceWorld(nodeFactory: nodeFactory)
        let viewModel = LevelSummaryViewModel(levelConfiguration: levelConfiguration, nodeFactory: nodeFactory, world: world)
        return LevelSummaryViewController(viewModel: viewModel)
    }
}
