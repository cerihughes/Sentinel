import UIKit

protocol UIContext {
    func navigate(with registrationLocator: RegistrationLocator, animated: Bool) -> Bool
    func leave(viewController: UIViewController, animated: Bool) -> Bool
}
