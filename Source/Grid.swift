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
        if let index = directions.index(of: direction) {
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

let undefinedPosition = GridPoint(x: -1, z: -1)

/**
 Describes the playing grid.
 */
class Grid {
    let width: Int
    let depth: Int

    private var grid: [[GridPiece]] = []

    var sentinelPosition: GridPoint = undefinedPosition
    var sentryPositions: Set<GridPoint> = []
    var startPosition: GridPoint = undefinedPosition
    var treePositions: Set<GridPoint> = []
    var rockPositions: Set<GridPoint> = []
    var synthoidPositions: Set<GridPoint> = []
    var currentPosition = undefinedPosition

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

    func build(at point: GridPoint) {
        buildFloor(point: point)
    }

    func processSlopes() {
        for z in 0 ..< depth {
            var startPoint = GridPoint(x: 0, z: z)
            processSlopes(from: startPoint, direction: .east)

            startPoint = GridPoint(x: width - 1, z: z)
            processSlopes(from: startPoint, direction: .west)
        }

        for x in 0 ..< width {
            var startPoint = GridPoint(x: x, z: 0)
            processSlopes(from: startPoint, direction: .south)

            startPoint = GridPoint(x: x, z: depth - 1)
            processSlopes(from: startPoint, direction: .north)
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

    var description: String {
        var desc = ""
        for z in 0 ..< depth {
            for x in 0 ..< width {
                if let piece = get(point: GridPoint(x: x, z: z)) {
                    desc += "\(piece) "
                }
            }
            desc += "\n"
        }
        return desc
    }

    private func buildFloor(point: GridPoint) {
        guard let piece = get(point: point) else {
            return
        }

        let slopeLevel = piece.buildFloor() - 0.5

        for direction in GridDirection.allCases {
            buildSlope(from: point, level: slopeLevel, direction: direction)
        }
    }

    private func buildSlope(from point: GridPoint, level: Float, direction: GridDirection) {
        let nextPoint = neighbour(of: point, direction: direction)
        if let next = get(point: nextPoint) {
            let nextLevel = next.level

            if level <= nextLevel {
                return
            }

            if level - nextLevel == 1.0 {
                buildFloor(point: nextPoint)
            }

            let nextSlopeLevel = next.buildSlope() - 1.0

            for direction in GridDirection.allValues(except: direction.opposite) {
                buildSlope(from: nextPoint, level: nextSlopeLevel, direction: direction)
            }
        }
    }

    private func processSlopes(from point: GridPoint, direction: GridDirection) {
        guard let firstPiece = get(point: point) else {
            return
        }

        var slopeLevel = firstPiece.isFloor ? firstPiece.level - 0.5 : firstPiece.level - 1.0

        var nextPoint = neighbour(of: point, direction: direction)
        var next = get(point: nextPoint)
        while next != nil {
            let nextExists = next!
            if nextExists.isFloor {
                slopeLevel = nextExists.level - 0.5
            } else {
                if nextExists.level == slopeLevel {
                    nextExists.add(slopeDirection: direction)
                    slopeLevel -= 1.0
                } else {
                    slopeLevel = nextExists.level - 1.0
                }
            }

            nextPoint = neighbour(of: nextPoint, direction: direction)
            next = get(point: nextPoint)
        }
    }

    private func neighbour(of point: GridPoint, direction: GridDirection) -> GridPoint {
        let deltas = direction.toDeltas()
        return point.transform(deltaX: deltas.x, deltaZ: deltas.z)
    }
}
