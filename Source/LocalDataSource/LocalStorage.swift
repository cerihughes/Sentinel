import Foundation

protocol LocalStorage {
    var gameScore: GameScore? { get set }
}

protocol JSONConverting {
    var encoder: JSONEncoder { get }
    var decoder: JSONDecoder { get }
}

class DefaultLocalStorage: JSONConverting {
    private let persistentDataStore: PersistentDataStore
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    init(persistentDataStore: PersistentDataStore) {
        self.persistentDataStore = persistentDataStore
    }

    func getDecodable<T: Decodable>(key: String, type: T.Type) -> T? {
        guard let data = persistentDataStore.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    func setEncodable<T: Encodable>(key: String, encodable: T) {
        guard let data = try? encoder.encode(encodable) else { return }
        persistentDataStore.set(data: data, forKey: key)
    }
}

extension DefaultLocalStorage: LocalStorage {
    static let gameScoreDataKey = "gameScoreDataKey"
    var gameScore: GameScore? {
        get {
            getDecodable(key: Self.gameScoreDataKey, type: GameScore.self)
        }
        set(newValue) {
            setEncodable(key: Self.gameScoreDataKey, encodable: newValue)
        }
    }
}
