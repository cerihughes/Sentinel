import Foundation

class GridPiece {
    let point: GridPoint

    var isFloor = true
    var level: Float = 0.0
    var slopes: Int = 0

    init(x: Int, z: Int) {
        point = GridPoint(x: x, z: z)
    }

    func has(slopeDirection: GridDirection) -> Bool {
        let rawValue = slopeDirection.rawValue
        return slopes & rawValue == rawValue
    }
}
