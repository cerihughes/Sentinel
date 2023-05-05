import Foundation

struct GridPieces {
    let width: Int
    let depth: Int
    private let pieces: [[GridPiece]]

    init(width: Int, depth: Int) {
        self.width = width
        self.depth = depth
        pieces = (0 ..< depth).map { z in
            (0 ..< width).map { x in
                    .init(x: x, z: z)
            }
        }
    }

    func get(point: GridPoint) -> GridPiece? {
        pieces[safe: point.z]?[safe: point.x]
    }
}

