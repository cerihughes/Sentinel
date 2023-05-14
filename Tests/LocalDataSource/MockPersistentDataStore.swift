import Foundation
@testable import Sentinel

class MockPersistentDataStore: PersistentDataStore {
    private var store = [String: Data]()
    func data(forKey key: String) -> Data? {
        store[key]
    }

    func set(data: Data?, forKey key: String) {
        store[key] = data
    }
}
