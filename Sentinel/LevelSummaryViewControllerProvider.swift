import UIKit

let levelSummaryIdentifier = "levelSummaryIdentifier"

class LevelSummaryViewControllerProvider: NSObject, ViewControllerProvider {

    // MARK: ViewControllerProvider

    func register(with registry: ViewControllerRegistry<RegistrationLocator>) {
        _ = registry.add(registryFunction: createViewController(id:context:))
    }

    // MARK: Private
    
    private func createViewController(id: RegistrationLocator, context: UIContext) -> UIViewController? {
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

        let materialFactory = MainMaterialFactory(level: levelConfiguration.level)
        let nodeFactory = NodeFactory(nodePositioning: nodePositioning,
                                      detectionRadius: levelConfiguration.opponentDetectionRadius * floorSize,
                                      materialFactory: materialFactory,
                                      options: [.showDetectionNode, .showVisionNode(false)])

        let world = SpaceWorld(nodeFactory: nodeFactory)
        let viewModel = LevelSummaryViewModel(levelConfiguration: levelConfiguration, nodeFactory: nodeFactory, world: world)
        return LevelSummaryViewController(ui: context, viewModel: viewModel)
    }
}
