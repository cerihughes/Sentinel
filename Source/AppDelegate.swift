import Madog
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let madog = Madog<RegistrationLocator>()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        window.makeKeyAndVisible()

        self.window = window

        #if DEBUG
        if isRunningUnitTests {
            window.rootViewController = UIViewController()
            return true
        }
        #endif

        madog.resolve(resolver: RuntimeResolver())
        let initialRL = RegistrationLocator.createIntroRegistrationLocator()
        let identifier = SingleUIIdentifier.createNavigationControllerIdentifier { navigationController in
            navigationController.isNavigationBarHidden = true
        }
        return madog.renderUI(identifier: identifier, token: initialRL, in: window)
    }
}

#if DEBUG
extension UIApplicationDelegate {
    var isRunningUnitTests: Bool {
        return NSClassFromString("XCTest") != nil
    }
}
#endif
