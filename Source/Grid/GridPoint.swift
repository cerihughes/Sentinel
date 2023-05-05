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
