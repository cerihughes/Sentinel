import Foundation

struct GridPoint: Equatable, Hashable {
    let x: Int
    let z: Int

    func transform(deltaX: Int, deltaZ: Int) -> GridPoint {
        return GridPoint(x: x + deltaX, z: z + deltaZ)
    }

    func angle(to point: GridPoint) -> Float {
        let ax = Float(x)
        let az = Float(z)
        let bx = Float(point.x)
        let bz = Float(point.z)
        var angle = atan2f(ax - bx, az - bz)
        while angle < 0 {
            angle += (2.0 * Float.pi)
        }
        return angle
    }
}

enum GridDirection: Int, CaseIterable {
    case north = 1
    case east = 2
    case south = 4
    case west = 8

    func toDeltas() -> (x: Int, z: Int) {
        switch self {
        case .north:
            return (x: 0, z: -1)
        case .east:
            return (x: 1, z: 0)
        case .south:
            return (x: 0, z: 1)
        case .west:
            return (x: -1, z: 0)
        }
    }

    static func allValues(except direction: GridDirection) -> [GridDirection] {
        var directions = allCases
        if let index = directions.firstIndex(of: direction) {
            directions.remove(at: index)
        }
        return directions
    }

    var opposite: GridDirection {
        switch self {
        case .north:
            return .south
        case .east:
            return .west
        case .south:
            return .north
        case .west:
            return .east
        }
    }
}

extension GridPoint {
    static let undefined = GridPoint(x: -1, z: -1)
}

/**
 Describes the playing grid.
 */
class Grid {
    let width: Int
    let depth: Int

    private var grid: [[GridPiece]] = []

    var sentinelPosition = GridPoint.undefined
    var sentryPositions: Set<GridPoint> = []
    var startPosition = GridPoint.undefined
    var treePositions: Set<GridPoint> = []
    var rockPositions: Set<GridPoint> = []
    var synthoidPositions: Set<GridPoint> = []
    var currentPosition = GridPoint.undefined

    init(width: Int, depth: Int) {
        self.width = width
        self.depth = depth

        for z in 0 ..< depth {
            var row: [GridPiece] = []
            for x in 0 ..< width {
                row.append(GridPiece(x: x, z: z))
            }
            grid.append(row)
        }
    }

    func get(point: GridPoint) -> GridPiece? {
        let x = point.x, z = point.z
        guard
            0 ..< width ~= x,
            0 ..< depth ~= z
        else {
            return nil
        }

        return grid[z][x]
    }

    var currentPiece: GridPiece? {
        return get(point: currentPosition)
    }
}
