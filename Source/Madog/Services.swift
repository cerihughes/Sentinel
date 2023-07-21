import Foundation
import Madog

let serviceProviderName = "serviceProviderName"

protocol Services {
    var localDataSource: LocalDataSource { get }
    var audioManager: AudioManager { get }
}

class DefaultServices: ServiceProvider, Services {
    let localDataSource: LocalDataSource
    let audioManager: AudioManager
    let name = serviceProviderName

    // MARK: ServiceProvider
    required init(context: ServiceProviderCreationContext) {
        let localStorage = DefaultLocalStorage(persistentDataStore: UserDefaults.standard)
        localDataSource = DefaultLocalDataSource(localStorage: localStorage)
        audioManager = DefaultAudioManager()
    }
}

protocol ServicesProvider {
    var services: Services? { get }
}

extension ServicesProvider {
    var localDataSource: LocalDataSource? { services?.localDataSource }
    var audioManager: AudioManager? { services?.audioManager }
}
