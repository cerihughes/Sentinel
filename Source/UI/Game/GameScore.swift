import Foundation

struct GameScore: Codable {
    var levelScores = [Int: LevelScore]()
}

struct LevelScore: Codable {
    var treesCreated = 0
    var treesAbsorbed = 0
    var rocksCreated = 0
    var rocksAbsorbed = 0
    var synthoidsCreated = 0
    var synthoidsAbsorbed = 0
    var teleports = 0
    var highestPoint = 0
    var sentriesAbsorbed = 0
}

extension LevelScore {
    mutating func pointReached(_ point: Int) {
        highestPoint = max(point, highestPoint)
    }
}
