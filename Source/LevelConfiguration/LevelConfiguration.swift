import Foundation

/**
 Describes the level and what it's made up of (trees, terrain, opponents etc.)
 */
protocol LevelConfiguration {
    var level: Int { get }

    var gridWidth: Int { get }
    var gridDepth: Int { get }

    var sentinelPlatformHeight: Int { get }
    var sentryCount: Int { get }

    var largePlateauSizeRange: CountableRange<Int> { get }
    var largePlateauCountRange: CountableRange<Int> { get }
    var smallPlateauSizeRange: CountableRange<Int> { get }
    var smallPlateauCountRange: CountableRange<Int> { get }

    var largePeakCountRange: CountableRange<Int> { get }
    var mediumPeakCountRange: CountableRange<Int> { get }
    var smallPeakCountRange: CountableRange<Int> { get }

    var treeCountRange: CountableRange<Int> { get }
}

struct DefaultLevelConfiguration: LevelConfiguration {
    let level: Int

    private let gridWidthRange = 24 ..< 32
    private let gridDepthRange = 16 ..< 24

    private let maxLevel = 99

    private var progression: Float {
        Float(level) / Float(maxLevel)
    }

    var gridWidth: Int {
        let adjustment = progression * Float(gridWidthRange.lowerBound - gridWidthRange.upperBound)
        return gridWidthRange.upperBound - Int(adjustment)
    }

    var gridDepth: Int {
        let adjustment = progression * Float(gridDepthRange.lowerBound - gridDepthRange.upperBound)
        return gridDepthRange.upperBound - Int(adjustment)
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
        if sentries > 3 {
            sentries = 3
        }
        return sentries
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
        return minCount ..< maxCount
    }
}
