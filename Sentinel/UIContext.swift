import UIKit

/**
 Passed into the functions that are invoked to create view controllers in the registry, allowing those VCs to perform
 further UI navigation tasks - e.g. dismissing themselves, or navigating to other VCs.
 */
protocol UIContext {
    func navigate(with registrationLocator: RegistrationLocator, animated: Bool) -> Bool
    func leave(viewController: UIViewController, animated: Bool) -> Bool
}
