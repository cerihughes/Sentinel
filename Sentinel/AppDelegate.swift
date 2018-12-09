import Madog
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let window = UIWindow()
    let madog = Madog(resolver: RuntimeResolver())

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window.makeKeyAndVisible()

        let initialRL = RegistrationLocator.createIntroRegistrationLocator()
        let identifier = SinglePageUIIdentifier.createNavigationControllerIdentifier { (navigationController) in
            navigationController.isNavigationBarHidden = true
        }
        return madog.renderSinglePageUI(identifier, with: initialRL, in: window)
    }

    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}
}
