import Foundation

enum Navigation: Equatable {
    case intro
    case lobby
    case levelSummary(level: Int)
    case game(level: Int)

    // Debug
    case stagingArea
}
