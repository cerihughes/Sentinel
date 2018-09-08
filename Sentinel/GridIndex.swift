import Foundation

enum GridQuadrant {
    case northWest, northEast, southWest, southEast

    // TODO: Replace when Swift 4.2 is out of beta
    static func allValues() -> [GridQuadrant] {
        return [.northWest, .northEast, .southWest, .southEast]
    }

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

class GridIndex: NSObject {
    private let index: [Int:[GridPiece]]

    convenience init(grid: Grid) {
        self.init(grid: grid, minX: 0, maxX: grid.width, minZ: 0, maxZ: grid.depth)
    }

    convenience init(grid: Grid, quadrant: GridQuadrant) {
        let xRange = quadrant.xRange(grid: grid)
        let zRange = quadrant.zRange(grid: grid)
        self.init(grid: grid,
                  minX: xRange.lowerBound,
                  maxX: xRange.upperBound,
                  minZ: zRange.lowerBound,
                  maxZ: zRange.upperBound)
    }

    init(grid: Grid, minX: Int, maxX: Int, minZ: Int, maxZ: Int) {
        var i: [Int:[GridPiece]] = [:]

        for z in minZ ..< maxZ {
            for x in minX ..< maxX {
                if let piece = grid.get(point: GridPoint(x: x, z: z)) {
                    if GridIndex.isValid(piece: piece, in: grid) {
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
        }

        index = i

        super.init()
    }

    func flatLevels() -> [Int] {
        return index.keys.sorted()
    }

    func pieces(at level: Int) -> [GridPiece] {
        if let array = index[level] {
            return array
        }

        return []
    }

    func highestFlatPieces() -> [GridPiece] {
        if let level = flatLevels().last {
            return pieces(at: level)
        }
        return []
    }

    func lowestFlatPieces() -> [GridPiece] {
        if let level = flatLevels().first {
            return pieces(at: level)
        }
        return []
    }

    func allPieces() -> [GridPiece] {
        var allPieces: [GridPiece] = []
        for level in flatLevels() {
            allPieces.append(contentsOf: pieces(at: level))
        }
        
        return allPieces
    }

    private static func isValid(piece: GridPiece, in grid: Grid) -> Bool {
        if !piece.isFlat {
            return false
        }

        let point = piece.point

        if grid.sentinelPosition == point {
            return false
        }

        if grid.guardianPositions.contains(point) {
            return false
        }

        if grid.startPosition == point {
            return false
        }

        return true
    }
}