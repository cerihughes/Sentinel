import UIKit

/**
 A protocol that describes an entity that wants to provide a VC for a given RegistrationLocator token by registering
 with the ViewControllerRegistry.

 TODO: Should this also be parameterised to <T>?
 */
protocol ViewControllerProvider {
    func register(with registry: ViewControllerRegistry<RegistrationLocator>)
}

protocol ViewControllerProviderFactory {
    static func createViewControllerProvider() -> ViewControllerProvider
}
