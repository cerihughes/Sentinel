import Foundation

/**
 For a given Grid (or part of a Grid), this represents a read-only description of its contents.
 */
struct FloorIndex {
    private let index: [Int: [GridPiece]]

    init(grid: Grid) {
        self.init(grid: grid, minX: 0, maxX: grid.width, minZ: 0, maxZ: grid.depth)
    }

    init(grid: Grid, minX: Int, maxX: Int, minZ: Int, maxZ: Int) {
        var i: [Int: [GridPiece]] = [:]

        for z in minZ ..< maxZ {
            for x in minX ..< maxX {
                if let piece = grid.get(point: GridPoint(x: x, z: z)), FloorIndex.isEmptyFloor(piece: piece, in: grid) {
                    let level = Int(piece.level)
                    var array = i[level]
                    if array == nil {
                        i[level] = [piece]
                    } else {
                        array!.append(piece)
                        i[level] = array! // Need to reassign as arrays (structs) are passed by value
                    }
                }
            }
        }

        index = i
    }

    func floorLevels() -> [Int] {
        index.keys.sorted()
    }

    func emptyFloorPieces(at level: Int) -> [GridPiece] {
        index[level] ?? []
    }

    func highestEmptyFloorPieces() -> [GridPiece] {
        if let level = floorLevels().last {
            return emptyFloorPieces(at: level)
        }
        return []
    }

    func lowestEmptyFloorPieces() -> [GridPiece] {
        if let level = floorLevels().first {
            return emptyFloorPieces(at: level)
        }
        return []
    }

    func allEmptyFloorPieces() -> [GridPiece] {
        var allPieces: [GridPiece] = []
        for level in floorLevels() {
            allPieces.append(contentsOf: emptyFloorPieces(at: level))
        }

        return allPieces
    }

    private static func isEmptyFloor(piece: GridPiece, in grid: Grid) -> Bool {
        guard piece.isFloor else { return false }

        let point = piece.point

        var invalidPositions: [GridPoint] = [grid.currentOrStartPosition]
        invalidPositions.append(grid.sentinelPosition)
        invalidPositions.append(contentsOf: grid.sentryPositions)
        invalidPositions.append(contentsOf: grid.synthoidPositions)
        invalidPositions.append(contentsOf: grid.rockPositions)
        invalidPositions.append(contentsOf: grid.treePositions)

        return !invalidPositions.contains(point)
    }
}

private extension Grid {
    var currentOrStartPosition: GridPoint {
        currentPosition == .undefined ? startPosition : currentPosition
    }
}
