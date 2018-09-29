import UIKit

let introIdentifier = "introIdentifier"

class IntroUI: NSObject {
    func register(with registry: ViewControllerRegistry<RegistrationLocator>) {
        _ = registry.add(registryFunction: createViewController(id:context:))
    }

    private func createViewController(id: RegistrationLocator, context: UIContext) -> UIViewController? {
        guard id.identifier == introIdentifier else {
            return nil
        }

        return IntroViewController(ui: context)
    }
}
