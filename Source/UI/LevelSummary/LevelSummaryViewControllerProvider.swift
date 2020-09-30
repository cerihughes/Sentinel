import Madog
import UIKit

class LevelSummaryViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(token: Navigation, navigationContext: ForwardBackNavigationContext) -> UIViewController? {
        guard
            case let .levelSummary(level) = token
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
        return LevelSummaryViewController(navigationContext: navigationContext, viewModel: viewModel)
    }
}
