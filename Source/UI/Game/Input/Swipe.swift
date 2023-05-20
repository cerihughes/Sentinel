import Foundation

struct Swipe {
    enum Direction: CaseIterable {
        case up, down, left, right
    }

    let direction: Direction
    let delta: Float

    static func from(_ point1: CGPoint, to point2: CGPoint) -> Swipe? {
        guard point1 != point2 else { return nil }
        let deltaX = Float(point2.x - point1.x)
        let deltaY = Float(point2.y - point1.y)
        let absDeltaX = deltaX < 0 ? -deltaX : deltaX
        let absDeltaY = deltaY < 0 ? -deltaY : deltaY

        if absDeltaX > absDeltaY {
            // Horizontal change is greater
            if absDeltaX == deltaX {
                return .init(direction: .right, delta: absDeltaX)
            } else {
                return .init(direction: .left, delta: absDeltaX)
            }
        } else {
            // Vertical change is greater
            if absDeltaY == deltaY {
                return .init(direction: .down, delta: absDeltaY)
            } else {
                return .init(direction: .up, delta: absDeltaY)
            }
        }
    }
}
