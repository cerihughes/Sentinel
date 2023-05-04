import Foundation
@testable import Sentinel

class MockLevelConfiguration: LevelConfiguration {
    var level = 1
    var opponentDetectionRadius = Float(5.0)
    var opponentRotationSteps = 12
    var opponentRotationTime = 1.0
    var opponentRotationPause = 5.0

    var gridWidth = 8
    var gridDepth = 8

    var sentinelPlatformHeight = 2
    var sentryCount = 0

    var largePlateauSizeRange = 1 ..< 1
    var largePlateauCountRange = 1 ..< 1
    var smallPlateauSizeRange = 1 ..< 1
    var smallPlateauCountRange = 1 ..< 1
    var largePeakCountRange = 1 ..< 1
    var mediumPeakCountRange = 1 ..< 1
    var smallPeakCountRange = 1 ..< 1
    var treeCountRange = 5 ..< 5
}
