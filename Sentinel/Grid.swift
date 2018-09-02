import Foundation

struct GridPoint {
    let x: Int
    let z: Int

    func transform(deltaX: Int, deltaZ: Int) -> GridPoint {
        return GridPoint(x: x + deltaX, z: z + deltaZ)
    }
}

enum GridShape {
    case flat, slopeUpX, slopeDownX, slopeUpZ, slopeDownZ
}

class GridPiece: NSObject {
    var shapes: [GridShape] = [.flat]
    var level: Int = 0

    var isFlat: Bool {
        return shapes == [.flat]
    }

    func set(level: Int, with shape: GridShape) {
        if shape == .flat || isFlat {
            shapes.removeAll()
        }

        if (level > self.level) {
            self.level = level
            shapes.removeAll()
        }

        if !shapes.contains(shape) {
            shapes.append(shape)
        }
    }

    override var description: String {
        let shapes = shapeValue()
        let hex = String(shapes, radix: 16, uppercase: false)
        return "\(hex):\(level)"
    }

    private func shapeValue() -> UInt8 {
        var value: UInt8 = 0
        for shape in shapes {
            switch shape {
            case .flat:
                value |= 0
            case .slopeUpZ:
                value |= 1 << 0
            case .slopeDownX:
                value |= 1 << 1
            case .slopeDownZ:
                value |= 1 << 2
            case .slopeUpX:
                value |= 1 << 3
            }
        }
        return value
    }
}

class Grid: NSObject {
    let width: Int
    let depth: Int
    private var grid: [[GridPiece]] = []

    init(width: Int, depth: Int) {
        self.width = width
        self.depth = depth

        for _ in 0..<depth {
            var row: [GridPiece] = []
            for _ in 0..<width {
                row.append(GridPiece())
            }
            grid.append(row)
        }
        super.init()
    }

    func build(at point: GridPoint) {
        let piece = get(point: point)
        let level = piece.level + 1

        raise(point: point, level: level, shape: .flat)
    }

    func get(point: GridPoint) -> GridPiece {
        return grid[point.z][point.x]
    }

    override var description: String {
        var desc = ""
        for z in 0 ..< depth {
            for x in 0 ..< width {
                let piece = get(point: GridPoint(x: x, z: z))
                desc += "\(piece) "
            }
            desc += "\n"
        }
        return desc
    }
}

extension Grid {
    private enum GridDirection {
        case north, east, south, west

        // TODO: Replace when Swift 4.2 is out of beta
        static func allValues() -> [GridDirection] {
            return [.north, .east, .south, .west]
        }

        static func allValues(except direction: GridDirection) -> [GridDirection] {
            var directions = allValues()
            if let index = directions.index(of:direction) {
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

        func toShape() -> GridShape {
            switch self {
            case .north:
                return .slopeUpZ
            case .east:
                return .slopeDownX
            case .south:
                return .slopeDownZ
            case .west:
                return .slopeUpX

            }
        }
    }

    private func raise(point: GridPoint,
                       level: Int,
                       shape: GridShape,
                       processDirections: [GridDirection] = GridDirection.allValues()) {
        let piece = get(point: point)
        piece.set(level: level, with: shape)

        for direction in processDirections {
            processNeighbour(of: point,
                             direction: direction,
                             level: level)
        }
    }

//    private func increment(point: GridPoint, shape: GridShape) -> Int {
//        let piece = get(point: point)
//        var level = piece.level
//        if piece.isFlat {
//            level += 1
//        }
//        piece.set(level: level, with: shape)
//        return level
//    }

    private func processNeighbour(of point: GridPoint, direction: GridDirection, level: Int) {
        let deltas = direction.toDeltas()
        if let neighbourPoint = neighbour(of: point, deltaX: deltas.x, deltaZ: deltas.z) {
            let neighbour = get(point: neighbourPoint)
            let neighbourLevel = neighbour.level

            if level == 0 || level < neighbourLevel || (level == neighbourLevel && neighbour.isFlat) {
                return
            }

            let shape = direction.toShape()
            if level != neighbourLevel && !neighbour.isFlat {
                let directions = GridDirection.allValues(except: direction.opposite)
                raise(point: neighbourPoint, level: level - 1, shape: shape, processDirections: directions)
            }
            
            raise(point: neighbourPoint, level: level - 1, shape: shape, processDirections: [])
        }
    }

    private func neighbour(of point: GridPoint, deltaX: Int, deltaZ: Int) -> GridPoint? {
        let newPoint = point.transform(deltaX: deltaX, deltaZ: deltaZ)
        guard
            0 ..< width ~= newPoint.x,
            0 ..< depth ~= newPoint.z
            else {
                return nil
        }
        return newPoint
    }
}
