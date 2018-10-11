import UIKit

protocol ViewControllerProviderFactory {
    func createViewControllerProviders() -> [ViewControllerProvider]
}
