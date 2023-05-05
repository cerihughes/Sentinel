import Foundation

enum GridQuadrant: CaseIterable {
    case northWest, northEast, southWest, southEast

    func xRange(grid: Grid) -> Range<Int> {
        switch self {
        case .northWest, .southWest:
            return 0 ..< grid.width / 2
        default:
            return grid.width / 2 ..< grid.width
        }
    }

    func zRange(grid: Grid) -> Range<Int> {
        switch self {
        case .northWest, .northEast:
            return 0 ..< grid.depth / 2
        default:
            return grid.depth / 2 ..< grid.depth
        }
    }

    func contains(point: GridPoint, grid: Grid) -> Bool {
        let x = xRange(grid: grid)
        let z = zRange(grid: grid)
        return x.contains(point.x) && z.contains(point.z)
    }
}
