import UIKit

class ViewControllerRegistry<T>: NSObject {
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
