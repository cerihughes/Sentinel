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

    var opposite: GridQuadrant {
        switch self {
        case .northWest:
            return .southEast
        case .northEast:
            return .southWest
        case .southWest:
            return .northEast
        case .southEast:
            return .northWest
        }
    }
}

/**
 For a given Grid (or part of a Grid), this represents a read-only description of its contents.
 */
struct FloorIndex {
    private let index: [Int: [GridPiece]]

    init(grid: Grid) {
        self.init(grid: grid, minX: 0, maxX: grid.width, minZ: 0, maxZ: grid.depth)
    }

    init(grid: Grid, quadrant: GridQuadrant) {
        let xRange = quadrant.xRange(grid: grid)
        let zRange = quadrant.zRange(grid: grid)
        self.init(grid: grid,
                  minX: xRange.lowerBound,
                  maxX: xRange.upperBound,
                  minZ: zRange.lowerBound,
                  maxZ: zRange.upperBound)
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
