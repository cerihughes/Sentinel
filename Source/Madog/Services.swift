import Foundation
import Provident
import Madog

let serviceProviderName = "serviceProviderName"

protocol Services {
    var localDataSource: LocalDataSource { get }
    var audioManager: AudioManager { get }
}

class DefaultServices: ServiceProvider, Services {
    let localDataSource: LocalDataSource
    let audioManager: AudioManager

    // MARK: ServiceProvider
    override init(context: ServiceProviderCreationContext) {
        let localStorage = DefaultLocalStorage(persistentDataStore: UserDefaults.standard)
        localDataSource = DefaultLocalDataSource(localStorage: localStorage)
        audioManager = DefaultAudioManager()

        super.init(context: context)
        name = serviceProviderName
    }
}

protocol ServicesProvider {
    var services: Services? { get }
}

extension ServicesProvider {
    var localDataSource: LocalDataSource? { services?.localDataSource }
    var audioManager: AudioManager? { services?.audioManager }
}
