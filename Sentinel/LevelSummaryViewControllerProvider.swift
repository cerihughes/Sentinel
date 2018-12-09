import Madog
import UIKit

fileprivate let levelSummaryIdentifier = "levelSummaryIdentifier"

class LevelSummaryViewControllerProvider: PageObject {
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

    // Private

    private func createViewController(token: Any, context: Context) -> UIViewController? {
        guard
            let id = token as? RegistrationLocator,
            id.identifier == levelSummaryIdentifier,
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
