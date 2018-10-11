import UIKit

/**
 A registry that looks up view controllers for a given token <T>. This token should be a type that is able to uniquely
 identify any "page" in an app, and also provide any data that the page needs to render. A good example would be a
 URL object, but this isn't mandatory.

 The registry works by registering a number of functions. To retrieve a page, the token <T> is passed into all
 retgistered functions, and the 1st non-nil VC that comes back is used as the return value.

 Note that registrants should make sure they don't "overlap" - if more than 1 registrant could potentially return a
 VC for the same token, behaviour is undefined - there's no guarantee which will be returned first.
 */
class ViewControllerRegistry<T> {
    typealias ViewControllerRegistryFunction = (T, UIContext) -> UIViewController?

    private var registry: [UUID:ViewControllerRegistryFunction] = [:]

    weak var ui: UI?

    func add(registryFunction: @escaping ViewControllerRegistryFunction) -> UUID {
        let token = UUID()
        registry[token] = registryFunction
        return token
    }

    func removeRegistryFunction(token: UUID) {
        registry.removeValue(forKey: token)
    }

    func createViewController(from id: T) -> UIViewController? {
        guard let ui = ui else {
            return nil
        }

        for function in registry.values {
            if let viewController = function(id, ui) {
                return viewController
            }
        }
        return nil
    }
}
