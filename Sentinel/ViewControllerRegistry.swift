import UIKit

class ViewControllerRegistry<T>: NSObject {
    typealias ViewControllerRegistryFunction = (T) -> UIViewController?

    private var registry: [UUID:ViewControllerRegistryFunction] = [:]

    func add(registryFunction: @escaping ViewControllerRegistryFunction) -> UUID {
        let token = UUID()
        registry[token] = registryFunction
        return token
    }

    func removeRegistryFunction(token: UUID) {
        registry.removeValue(forKey: token)
    }

    func createViewController(from id: T) -> UIViewController? {
        for function in registry.values {
            if let viewController = function(id) {
                return viewController
            }
        }
        return nil
    }
}
