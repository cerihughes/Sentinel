import Madog
import UIKit

class TypedViewControllerProvider: SingleViewControllerProvider<Navigation>, ServicesProvider {
    var services: Services?

    // MARK: SingleViewControllerProvider

    override final func configure(with serviceProviders: [String: ServiceProvider]) {
        super.configure(with: serviceProviders)

        services = serviceProviders[serviceProviderName] as? Services
    }

    override func createViewController(token: Navigation, context: Context) -> UIViewController? {
        guard
            let navigationContext = context as? ForwardBackNavigationContext
        else {
            return nil
        }

        return createViewController(token: token, navigationContext: navigationContext)
    }

    func createViewController(token: Navigation, navigationContext: ForwardBackNavigationContext) -> UIViewController? {
        // Override
        return nil
    }
}
