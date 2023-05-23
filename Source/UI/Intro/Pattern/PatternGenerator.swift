import Foundation

protocol Pattern {
    var width: Int { get }
    var depth: Int { get }

    func level(at point: GridPoint) -> Int
}

class PatternGenerator {
    private let pattern: Pattern
    private let builder: GridBuilder

    init(pattern: Pattern) {
        self.pattern = pattern
        builder = .init(width: pattern.width, depth: pattern.depth)
    }

    func generate() -> Grid {
        for z in 0 ..< pattern.depth {
            for x in 0 ..< pattern.width {
                let point = GridPoint(x: x, z: z)
                if pattern.level(at: point) == 1 {
                    builder.buildFloor(at: point)
                }
            }
        }
        builder.processSlopes()
        return builder.buildGrid()
    }
}
