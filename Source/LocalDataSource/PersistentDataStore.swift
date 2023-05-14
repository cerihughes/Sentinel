import Foundation

protocol PersistentDataStore {
    func data(forKey key: String) -> Data?
    func set(data: Data?, forKey key: String)
}

extension UserDefaults: PersistentDataStore {
    func set(data: Data?, forKey key: String) {
        set(data, forKey: key)
    }
}
