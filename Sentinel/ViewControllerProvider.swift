import UIKit

protocol ViewControllerProvider {
    associatedtype T
    func register(with registry: ViewControllerRegistry<T>)
}
