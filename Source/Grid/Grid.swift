import Foundation

/**
 Describes the playing grid.
 */
class Grid {
    let width: Int
    let depth: Int
    private let pieces: [[GridPiece]]

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
        pieces = (0 ..< depth).map { z in
            (0 ..< width).map { x in .init(x: x, z: z) }
        }
    }

    func piece(at point: GridPoint) -> GridPiece? {
        pieces[safe: point.z]?[safe: point.x]
    }

    var currentPiece: GridPiece? {
        piece(at: currentPosition)
    }
}

extension Grid {
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
                let intersected = $0.intersected(quadrant: quadrant, grid: self)
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
        floorLevels().map { emptyFloorPieces(at: $0) }
            .reduce([], +)
    }
}

private extension Array where Element == GridPiece {
    func intersected(quadrant: GridQuadrant, grid: Grid) -> [GridPiece] {
        filter { grid.piece($0, isInQuadrant: quadrant) }
    }
}

private extension Grid {
    var currentOrStartPosition: GridPoint {
        currentPosition == .undefined ? startPosition : currentPosition
    }

    var occupiedPositions: [GridPoint] {
        var invalidPositions: [GridPoint] = [currentOrStartPosition]
        invalidPositions.append(sentinelPosition)
        invalidPositions.append(contentsOf: sentryPositions)
        invalidPositions.append(contentsOf: synthoidPositions)
        invalidPositions.append(contentsOf: rockPositions)
        invalidPositions.append(contentsOf: treePositions)
        return invalidPositions
    }
}
