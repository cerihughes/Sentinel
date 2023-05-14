import Foundation
import Provident
import Madog

let serviceProviderName = "serviceProviderName"

protocol Services {
    var localDataSource: LocalDataSource { get }
}

class DefaultServices: ServiceProvider, Services {
    let localDataSource: LocalDataSource

    // MARK: ServiceProvider
    override init(context: ServiceProviderCreationContext) {
        let localStorage = DefaultLocalStorage(persistentDataStore: UserDefaults.standard)
        localDataSource = DefaultLocalDataSource(localStorage: localStorage)

        super.init(context: context)
        name = serviceProviderName
    }
}

protocol ServicesProvider {
    var services: Services? { get }
}

extension ServicesProvider {
    var localDataSource: LocalDataSource? { services?.localDataSource }
}
