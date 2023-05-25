import Foundation

enum Navigation: Equatable {
    case intro
    case lobby
    case gamePreview(level: Int)
    case game(level: Int)
    case gameSummary(level: Int)

    #if DEBUG
    // Debug
    case stagingArea

    // Scenario Test
    case multipleOpponentAbsorbScenario
    #endif
}
