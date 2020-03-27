import Madog
import UIKit

private let levelSummaryIdentifier = "levelSummaryIdentifier"

class LevelSummaryViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(registrationLocator: RegistrationLocator, navigationContext: ForwardBackNavigationContext) -> UIViewController? {
        guard registrationLocator.identifier == levelSummaryIdentifier,
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
                                      materialFactory: materialFactory,
                                      options: [.showDetectionNode, .showVisionNode(false)])

        let world = SpaceWorld(nodeFactory: nodeFactory)
        let viewModel = LevelSummaryViewModel(levelConfiguration: levelConfiguration, nodeFactory: nodeFactory, world: world)
        return LevelSummaryViewController(navigationContext: navigationContext, viewModel: viewModel)
    }
}

extension RegistrationLocator {
    static func createLevelSummaryRegistrationLocator(level: Int) -> RegistrationLocator {
        return RegistrationLocator(identifier: levelSummaryIdentifier, level: level)
    }
}
