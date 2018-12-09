import Madog
import UIKit

fileprivate let stagingAreaIdentifier = "stagingAreaIdentifier"

class StagingAreaViewControllerProvider: PageObject {
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
        guard let id = token as? RegistrationLocator, id.identifier == stagingAreaIdentifier else {
            return nil
        }

        let viewModel = StagingAreaViewModel()

        return StagingAreaViewController(viewModel: viewModel)
    }
}

extension RegistrationLocator {
    static func createStagingAreaRegistrationLocator() -> RegistrationLocator {
        return RegistrationLocator(identifier: stagingAreaIdentifier, level: nil)
    }
}
