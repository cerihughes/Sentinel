import Foundation

enum GridQuadrant: CaseIterable {
    case northWest, northEast, southWest, southEast

    func xRange(for sizeable: Sizeable) -> Range<Int> {
        switch self {
        case .northWest, .southWest:
            return 0 ..< sizeable.width / 2
        default:
            return sizeable.width / 2 ..< sizeable.width
        }
    }

    func zRange(for sizeable: Sizeable) -> Range<Int> {
        switch self {
        case .northWest, .northEast:
            return 0 ..< sizeable.depth / 2
        default:
            return sizeable.depth / 2 ..< sizeable.depth
        }
    }

    func contains(point: GridPoint, sizeable: Sizeable) -> Bool {
        let x = xRange(for: sizeable)
        let z = zRange(for: sizeable)
        return x.contains(point.x) && z.contains(point.z)
    }
}

extension Sizeable {
    func point(_ point: GridPoint, isInQuadrant quadrant: GridQuadrant) -> Bool {
        quadrant.contains(point: point, sizeable: self)
    }
}
