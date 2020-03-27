import Madog
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let window = UIWindow()
    let madog = Madog<RegistrationLocator>()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window.makeKeyAndVisible()

        madog.resolve(resolver: RuntimeResolver())
        let initialRL = RegistrationLocator.createIntroRegistrationLocator()
        let identifier = SingleUIIdentifier.createNavigationControllerIdentifier { (navigationController) in
            navigationController.isNavigationBarHidden = true
        }
        return madog.renderUI(identifier: identifier, token: initialRL, in: window)
    }

    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}
}
