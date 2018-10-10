import UIKit

let introIdentifier = "introIdentifier"

class IntroUI: NSObject, ViewControllerProvider {

    // MARK: ViewControllerProvider

    func register(with registry: ViewControllerRegistry<RegistrationLocator>) {
        _ = registry.add(registryFunction: createViewController(id:context:))
    }

    // Private

    private func createViewController(id: RegistrationLocator, context: UIContext) -> UIViewController? {
        guard id.identifier == introIdentifier else {
            return nil
        }

        return IntroViewController(ui: context)
    }
}
