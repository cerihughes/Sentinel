import Foundation

enum GridDirection: Int, CaseIterable {
    case north = 1
    case east = 2
    case south = 4
    case west = 8

    static func allValues(except direction: GridDirection) -> [GridDirection] {
        var directions = allCases
        if let index = directions.firstIndex(of: direction) {
            directions.remove(at: index)
        }
        return directions
    }
}
