import Foundation

class GridPiece {
    let point: GridPoint

    var isFloor = true
    var level: Float = 0.0
    var slopes: Int = 0

    init(x: Int, z: Int) {
        point = GridPoint(x: x, z: z)
    }

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

    func has(slopeDirection: GridDirection) -> Bool {
        let rawValue = slopeDirection.rawValue
        return slopes & rawValue == rawValue
    }
}
