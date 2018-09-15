import Foundation

struct LevelConfiguration {
    let level: Int
    let maxLevel = 99

    var progression: Float {
        return Float(level) / Float(maxLevel)
    }

    var sentinelPlatformHeight: Int {
        var platformHeight = (level / 10) + 1
        if platformHeight > 4 {
            platformHeight = 4
        }
        return platformHeight
    }

    var sentryCount: Int {
        var sentries = level / 10
        if sentries > 5 {
            sentries = 5
        }
        return sentries
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
        var adjustment = level / 5
        if adjustment > 6 {
            adjustment = 6
        }

        let minCount = (16 - adjustment)
        let maxCount = (24 - adjustment)
        return minCount..<maxCount
    }
}
