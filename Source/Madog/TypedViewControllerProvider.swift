import Madog
import UIKit

class TypedViewControllerProvider: ViewControllerProvider, ServicesProvider {
    var services: Services?

    // MARK: SingleViewControllerProvider

    final func configure(with serviceProviders: [String: ServiceProvider]) {
        services = serviceProviders[serviceProviderName] as? Services
    }

    func createViewController(token: Navigation, context: AnyContext<Navigation>) -> ViewController? {
        nil
    }
}
