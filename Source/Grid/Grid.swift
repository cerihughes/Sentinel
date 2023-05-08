import Foundation

/**
 Describes the playing grid.
 */
struct Grid {
    let width: Int
    let depth: Int
    let pieces: [[GridPiece]]

    let sentinelPosition: GridPoint
    var sentryPositions: [GridPoint]
    let startPosition: GridPoint
    var treePositions: [GridPoint]
    private var rockPositions = [GridPoint: Int]()
    var synthoidPositions: [GridPoint]
    var currentPosition: GridPoint

    init(
        width: Int,
        depth: Int,
        pieces: [[GridPiece]],
        sentinelPosition: GridPoint,
        sentryPositions: [GridPoint],
        startPosition: GridPoint,
        treePositions: [GridPoint],
        synthoidPositions: [GridPoint],
        currentPosition: GridPoint
    ) {
        self.width = width
        self.depth = depth
        self.pieces = pieces
        self.sentinelPosition = sentinelPosition
        self.sentryPositions = sentryPositions
        self.startPosition = startPosition
        self.treePositions = treePositions
        self.synthoidPositions = synthoidPositions
        self.currentPosition = currentPosition
    }

    func piece(at point: GridPoint) -> GridPiece? {
        pieces[safe: point.z]?[safe: point.x]
    }

    var currentPiece: GridPiece? {
        piece(at: currentPosition)
    }

    func emptyFloorPieces() -> [GridPiece] {
        let occupiedPositions = occupiedPositions()
        return floorPieces.filter { !occupiedPositions.contains($0.point) }
    }

    func allRockPositions() -> [GridPoint] {
        Array(rockPositions.keys)
    }

    func rockCount(at point: GridPoint) -> Int {
        rockPositions[point] ?? 0
    }

    mutating func addRock(at point: GridPoint) {
        if let count = rockPositions[point] {
            rockPositions[point] = count + 1
        } else {
            rockPositions[point] = 1
        }
    }

    mutating func removeRock(at point: GridPoint) {
        if let count = rockPositions[point] {
            rockPositions[point] = count == 1 ? nil : count - 1
        }
    }

    private var flatPieces: [GridPiece] {
        pieces.flatMap { $0 }
    }

    private var floorPieces: [GridPiece] {
        flatPieces.filter { $0.isFloor }
    }

    private func occupiedPositions() -> [GridPoint] {
        [sentinelPosition] + sentryPositions + treePositions + rockPositions.keys + synthoidPositions
    }
}
