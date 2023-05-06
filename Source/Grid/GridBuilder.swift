import Foundation

class GridBuilder {
    let width: Int
    let depth: Int
    private let pieces: [[GridPiece]]

    var sentinelPosition: GridPoint?
    var sentryPositions = [GridPoint]()
    var startPosition: GridPoint?
    var treePositions = [GridPoint]()
    var synthoidPositions = [GridPoint]()

    init(width: Int, depth: Int) {
        self.width = width
        self.depth = depth
        pieces = (0 ..< depth).map { z in
            (0 ..< width).map { x in .init(x: x, z: z) }
        }
    }

    func buildFloor(at point: GridPoint) {
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

    func buildGrid() -> Grid {
        .init(
            width: width,
            depth: depth,
            pieces: pieces,
            sentinelPosition: sentinelPosition ?? .undefined,
            sentryPositions: sentryPositions,
            startPosition: startPosition ?? .undefined,
            treePositions: treePositions,
            rockPositions: [],
            synthoidPositions: synthoidPositions,
            currentPosition: .undefined
        )
    }

    func piece(at point: GridPoint) -> GridPiece? {
        pieces[safe: point.z]?[safe: point.x]
    }

    private func buildFloor(point: GridPoint) {
        guard let piece = piece(at: point) else { return }

        let slopeLevel = piece.buildFloor() - 0.5
        for direction in GridDirection.allCases {
            buildSlope(from: point, level: slopeLevel, direction: direction)
        }
    }

    private func buildSlope(from point: GridPoint, level: Float, direction: GridDirection) {
        let nextPoint = neighbour(of: point, direction: direction)
        if let nextPiece = piece(at: nextPoint) {
            let nextLevel = nextPiece.level

            if level <= nextLevel {
                return
            }

            if level - nextLevel == 1.0 {
                buildFloor(point: nextPoint)
            }

            let nextSlopeLevel = nextPiece.buildSlope() - 1.0

            for direction in GridDirection.allCases(except: direction.opposite) {
                buildSlope(from: nextPoint, level: nextSlopeLevel, direction: direction)
            }
        }
    }

    private func processSlopes(from point: GridPoint, direction: GridDirection) {
        guard let firstPiece = piece(at: point) else { return }

        var slopeLevel = firstPiece.isFloor ? firstPiece.level - 0.5 : firstPiece.level - 1.0
        var nextPoint = neighbour(of: point, direction: direction)
        var nextPiece = piece(at: nextPoint)
        while nextPiece != nil {
            let nextExists = nextPiece!
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
            nextPiece = piece(at: nextPoint)
        }
    }

    private func neighbour(of point: GridPoint, direction: GridDirection) -> GridPoint {
        let deltas = direction.toDelta()
        return point.transform(deltaX: deltas.x, deltaZ: deltas.z)
    }
}

extension GridBuilder {
    func emptyFloorPiecesByLevel(in quadrant: GridQuadrant? = nil) -> [Int: [GridPiece]] {
        var sorted: [Int: [GridPiece]] = [:]

        for row in pieces {
            for piece in row {
                if piece.isFloor, !occupiedPositions.contains(piece.point) {
                    let level = Int(piece.level)
                    var array = sorted[level]
                    if array == nil {
                        sorted[level] = [piece]
                    } else {
                        array!.append(piece)
                        sorted[level] = array! // Need to reassign as arrays (structs) are passed by value
                    }
                }
            }
        }

        if let quadrant {
            sorted = sorted.compactMapValues {
                let intersected = $0.intersected(quadrant: quadrant, sizeable: self)
                if intersected.isEmpty {
                    return nil
                } else {
                    return intersected
                }
            }
        }
        return sorted
    }
}

private extension GridBuilder {
    var occupiedPositions: [GridPoint] {
        var invalidPositions = [GridPoint]()
        if let startPosition {
            invalidPositions.append(startPosition)
        }
        if let sentinelPosition {
            invalidPositions.append(sentinelPosition)
        }
        invalidPositions.append(contentsOf: sentryPositions)
        invalidPositions.append(contentsOf: synthoidPositions)
        invalidPositions.append(contentsOf: treePositions)
        return invalidPositions
    }
}

extension Dictionary where Key == Int, Value == [GridPiece] {
    func floorLevels() -> [Int] {
        keys.sorted()
    }

    func emptyFloorPieces(at level: Int) -> [GridPiece] {
        self[level] ?? []
    }

    func highestEmptyFloorPieces() -> [GridPiece] {
        guard let highestLevel = floorLevels().last else { return [] }
        return emptyFloorPieces(at: highestLevel)
    }

    func lowestEmptyFloorPieces() -> [GridPiece] {
        guard let lowest = floorLevels().first else { return [] }
        return emptyFloorPieces(at: lowest)
    }

    func allEmptyFloorPieces() -> [GridPiece] {
        floorLevels().flatMap { emptyFloorPieces(at: $0) }
    }
}

private extension Array where Element == GridPiece {
    func intersected(quadrant: GridQuadrant, sizeable: Sizeable) -> [GridPiece] {
        filter { sizeable.piece($0, isInQuadrant: quadrant) }
    }
}
private extension GridPoint {
    func transform(deltaX: Int, deltaZ: Int) -> GridPoint {
        return GridPoint(x: x + deltaX, z: z + deltaZ)
    }
}

private extension GridPiece {
    func buildFloor() -> Float {
        if isFloor {
            level += 1.0
        } else {
            isFloor = true
            level += 0.5
        }
        return level
    }

    func buildSlope() -> Float {
        if isFloor {
            level += 0.5
            isFloor = false
        } else {
            level += 1.0
        }
        return level
    }

    func add(slopeDirection: GridDirection) {
        slopes |= slopeDirection.rawValue
    }
}

private extension GridDirection {
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

    func toDelta() -> (x: Int, z: Int) {
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
}
