import UIKit

let stagingAreaIdentifier = "stagingAreaIdentifier"

class StagingAreaUI: NSObject {
    func register(with registry: ViewControllerRegistry<RegistrationLocator>) {
        _ = registry.add(registryFunction: createViewController(id:context:))
    }

    private func createViewController(id: RegistrationLocator, context: UIContext) -> UIViewController? {
        guard id.identifier == stagingAreaIdentifier else {
            return nil
        }

        let viewModel = StagingAreaViewModel()

        return StagingAreaViewController(ui: context, viewModel: viewModel)
    }
}
