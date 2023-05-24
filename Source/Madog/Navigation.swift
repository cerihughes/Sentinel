import Foundation

enum Navigation: Equatable {
    case intro
    case lobby
    case levelSummary(level: Int)
    case game(level: Int)
    case levelComplete(level: Int)

    #if DEBUG
    // Debug
    case stagingArea

    // Scenario Test
    case multipleOpponentAbsorbScenario
    #endif
}
