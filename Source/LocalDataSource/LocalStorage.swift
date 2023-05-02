import Foundation

protocol LocalStorage {
    var gameScore: GameScore? { get set }
}

protocol JSONConverting {
    var encoder: JSONEncoder { get }
    var decoder: JSONDecoder { get }
}

class DefaultLocalStorage: JSONConverting {
    private let userDefaults: UserDefaults
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func getDecodable<T: Decodable>(key: String, type: T.Type) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    func setEncodable<T: Encodable>(key: String, encodable: T) {
        guard let data = try? encoder.encode(encodable) else { return }
        userDefaults.set(data, forKey: key)
    }
}

private let gameScoreDataKey = "gameScoreDataKey"

extension DefaultLocalStorage: LocalStorage {
    var gameScore: GameScore? {
        get {
            getDecodable(key: gameScoreDataKey, type: GameScore.self)
        }
        set(newValue) {
            setEncodable(key: gameScoreDataKey, encodable: newValue)
        }
    }
}
