import UIKit

let stagingAreaIdentifier = "stagingAreaIdentifier"

class StagingAreaViewControllerProvider: ViewControllerProviderFactory, ViewControllerProvider {

    // MARK: ViewControllerProviderFactory

    static func createViewControllerProvider() -> ViewControllerProvider {
        return StagingAreaViewControllerProvider()
    }

    // MARK: ViewControllerProvider

    func register(with registry: ViewControllerRegistry<RegistrationLocator>) {
        _ = registry.add(registryFunction: createViewController(id:context:))
    }

    // MARK: Private

    private func createViewController(id: RegistrationLocator, context: UIContext) -> UIViewController? {
        guard id.identifier == stagingAreaIdentifier else {
            return nil
        }

        let viewModel = StagingAreaViewModel()

        return StagingAreaViewController(ui: context, viewModel: viewModel)
    }
}
