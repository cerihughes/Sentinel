import Foundation

protocol LocalDataSource {
    var localStorage: LocalStorage { get }
}

class DefaultLocalDataSource: LocalDataSource {
    let localStorage: LocalStorage

    init(localStorage: LocalStorage) {
        self.localStorage = localStorage
    }
}
