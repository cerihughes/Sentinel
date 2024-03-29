import Foundation

struct GameScore: Equatable, Codable {
    var levelScores = [Int: LevelScore]()
}

struct LevelScore: Equatable, Codable {
    enum Outcome: Codable {
        case victory, defeat
    }
    var outcome: Outcome?
    var finalEnergy = 0
    var treesBuilt = 0
    var treesAbsorbed = 0
    var rocksBuilt = 0
    var rocksAbsorbed = 0
    var synthoidsBuilt = 0
    var synthoidsAbsorbed = 0
    var teleports = 0
    var highestPoint = 0
    var sentriesAbsorbed = 0
}

extension LevelScore {
    mutating func heightReached(_ height: Int) {
        highestPoint = max(height, highestPoint)
    }
}
