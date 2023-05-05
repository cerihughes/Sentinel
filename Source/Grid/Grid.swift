import Foundation

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

    func createFloorIndex() -> FloorIndex {
        .init(grid: self)
    }

    func createFloorIndex(for quadrant: GridQuadrant) -> FloorIndex {
        .init(grid: self, quadrant: quadrant)
    }
}

/**
 For a given Grid (or part of a Grid), this represents a read-only description of its contents.
 */
struct FloorIndex {
    private let index: [Int: [GridPiece]]

    fileprivate init(grid: Grid) {
        self.init(grid: grid, minX: 0, maxX: grid.width, minZ: 0, maxZ: grid.depth)
    }

    fileprivate init(grid: Grid, quadrant: GridQuadrant) {
        let xRange = quadrant.xRange(grid: grid)
        let zRange = quadrant.zRange(grid: grid)
        self.init(
            grid: grid,
            minX: xRange.lowerBound,
            maxX: xRange.upperBound,
            minZ: zRange.lowerBound,
            maxZ: zRange.upperBound
        )
    }

    private init(grid: Grid, minX: Int, maxX: Int, minZ: Int, maxZ: Int) {
        var i: [Int: [GridPiece]] = [:]

        for z in minZ ..< maxZ {
            for x in minX ..< maxX {
                if let piece = grid.get(point: GridPoint(x: x, z: z)), piece.isEmptyFloor(in: grid) {
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

private extension GridPiece {
    func isEmptyFloor(in grid: Grid) -> Bool {
        guard isFloor else { return false }
        return !grid.occupiedPositions.contains(point)
    }
}
