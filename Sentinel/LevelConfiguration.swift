import Foundation

struct LevelConfiguration {
    let level: Int
    let maxLevel = 99

    var progression: Float {
        return Float(level) / Float(maxLevel)
    }

    var difficultyAdjustment: Int {
        var adjustment = level / 10
        if adjustment > 3 {
            adjustment = 3
        }
        return adjustment
    }

    private let gridWidthRange = 24 ..< 32
    private let gridDepthRange = 16 ..< 24

    var gridWidth: Int {
        let adjustment = progression * Float(gridWidthRange.lowerBound - gridWidthRange.upperBound)
        return gridWidthRange.upperBound - Int(adjustment)

    }

    var gridDepth: Int {
        let adjustment = progression * Float(gridDepthRange.lowerBound - gridDepthRange.upperBound)
        return gridDepthRange.upperBound - Int(adjustment)
    }

    let largePlateauSizeRange = 8 ..< 12
    let largePlateauCountRange = 4 ..< 7
    let smallPlateauSizeRange = 5 ..< 7
    let smallPlateauCountRange = 6 ..< 8

    let largePeakCountRange = 2 ..< 6
    let mediumPeakCountRange = 3 ..< 8
    let smallPeakCountRange = 10 ..< 30

    var treeCountRange: CountableRange<Int> {
        let minCount = (16 - (difficultyAdjustment * 2)) / 4
        let maxCount = (24 - (difficultyAdjustment * 2)) / 4
        return minCount..<maxCount
    }
}
