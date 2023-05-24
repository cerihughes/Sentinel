import Foundation
@testable import Sentinel

class MockLevelConfiguration: LevelConfiguration {
    var level = 1

    var gridWidth = 8
    var gridDepth = 8

    var sentinelPlatformHeight = 2
    var sentryCount = 0

    var largePlateauSizeRange = 0 ..< 0
    var largePlateauCountRange = 0 ..< 0
    var smallPlateauSizeRange = 0 ..< 0
    var smallPlateauCountRange = 0 ..< 0
    var largePeakCountRange = 0 ..< 0
    var mediumPeakCountRange = 0 ..< 0
    var smallPeakCountRange = 0 ..< 0
    var treeCountRange = 5 ..< 5
}
