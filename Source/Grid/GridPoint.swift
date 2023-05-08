import Foundation

struct GridPoint: Equatable, Hashable {
    let x: Int
    let z: Int

    func angle(to point: GridPoint) -> Float {
        let ax = Float(x)
        let az = Float(z)
        let bx = Float(point.x)
        let bz = Float(point.z)
        var angle = atan2f(ax - bx, az - bz)
        while angle < 0 {
            angle += (2.0 * Float.pi)
        }
        return angle
    }
}

extension GridPoint {
    static let undefined = GridPoint(x: -1, z: -1)
}

extension Array where Element == GridPoint {
    func sortedByDistance(from other: GridPoint, ascending: Bool) -> Array {
        sorted {
            let first = ascending ? $1 : $0
            let second = ascending ? $0 : $1
            return first.distance(from: other) > second.distance(from: other)
        }
    }
}

private extension GridPoint {
    func distance(from other: GridPoint) -> Float {
        let xSquared = (x - other.x).squared()
        let zSquared = (z - other.z).squared()
        return sqrtf(.init(xSquared + zSquared))
    }
}

private extension Int {
    func squared() -> Int {
        self * self
    }
}
