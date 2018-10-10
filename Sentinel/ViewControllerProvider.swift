import UIKit

protocol ViewControllerProvider {
    func register(with registry: ViewControllerRegistry<RegistrationLocator>)
}
