import Foundation

protocol LevelConfiguration {
    var level: Int {get}
    var rotationSteps: Int {get}
    var rotationTime: TimeInterval {get}
    var rotationPause: TimeInterval {get}

    var gridWidth: Int {get}
    var gridDepth: Int {get}

    var sentinelPlatformHeight: Int {get}
    var sentryCount: Int {get}

    var largePlateauSizeRange: CountableRange<Int> {get}
    var largePlateauCountRange: CountableRange<Int> {get}
    var smallPlateauSizeRange: CountableRange<Int> {get}
    var smallPlateauCountRange: CountableRange<Int> {get}

    var largePeakCountRange: CountableRange<Int> {get}
    var mediumPeakCountRange: CountableRange<Int> {get}
    var smallPeakCountRange: CountableRange<Int> {get}

    var treeCountRange: CountableRange<Int> {get}
}

struct MainLevelConfiguration: LevelConfiguration {
    let level: Int
    let rotationSteps: Int = 12
    let rotationTime: TimeInterval = 0.3

    private let rotationPauseRange = 5.0 ..< 8.0
    private let gridWidthRange = 24 ..< 32
    private let gridDepthRange = 16 ..< 24

    private let maxLevel = 99

    private var progression: Float {
        return Float(level) / Float(maxLevel)
    }

    var rotationPause: TimeInterval {
        let adjustment = TimeInterval(progression) * rotationPauseRange.lowerBound - rotationPauseRange.upperBound
        return rotationPauseRange.upperBound - adjustment
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
        if sentries > 5 {
            sentries = 5
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
        return minCount..<maxCount
    }
}

struct TestLevelConfiguration: LevelConfiguration {
    let level: Int
    let rotationSteps: Int = 12
    let rotationTime: TimeInterval = 1.0
    let rotationPause: TimeInterval = 8.0

    let gridWidth = 16
    let gridDepth = 16

    let sentinelPlatformHeight: Int
    let sentryCount: Int

    let largePlateauSizeRange = 8 ..< 12
    let largePlateauCountRange = 0 ..< 0
    let smallPlateauSizeRange = 5 ..< 7
    let smallPlateauCountRange = 0 ..< 0

    let largePeakCountRange = 0 ..< 0
    let mediumPeakCountRange = 0 ..< 0
    let smallPeakCountRange = 0 ..< 0

    let treeCountRange = 10 ..< 10
}
