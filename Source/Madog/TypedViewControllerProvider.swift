import Madog
import UIKit

class TypedViewControllerProvider: SingleViewControllerProvider<Navigation>, ServicesProvider {
    var services: Services?

    // MARK: SingleViewControllerProvider

    override final func configure(with serviceProviders: [String: ServiceProvider]) {
        super.configure(with: serviceProviders)

        services = serviceProviders[serviceProviderName] as? Services
    }
}
