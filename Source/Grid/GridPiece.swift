import Foundation

struct GridPiece {
    let point: GridPoint
    let isFloor: Bool
    let level: Float
    private let slopes: Int

    init(point: GridPoint, isFloor: Bool, level: Float, slopes: Int) {
        self.point = point
        self.isFloor = isFloor
        self.level = level
        self.slopes = slopes
    }

    func has(slopeDirection: GridDirection) -> Bool {
        let rawValue = slopeDirection.rawValue
        return slopes & rawValue == rawValue
    }
}
