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
}
