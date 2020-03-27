import Madog
import UIKit

private let stagingAreaIdentifier = "stagingAreaIdentifier"

class StagingAreaViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(registrationLocator: RegistrationLocator, navigationContext: ForwardBackNavigationContext) -> UIViewController? {
        guard registrationLocator.identifier == stagingAreaIdentifier else {
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
