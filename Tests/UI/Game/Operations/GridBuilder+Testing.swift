@testable import Sentinel

extension GridPoint {
    static let startPosition = GridPoint(x: 0, z: 2)
    static let sentinelPosition = GridPoint(x: 2, z: 2)
}

extension GridBuilder {
    static func createGridBuilder() -> GridBuilder {
        let builder = GridBuilder(width: 5, depth: 5)
        builder.startPosition = .startPosition
        builder.synthoidPositions.append(.startPosition)
        builder.sentinelPosition = .sentinelPosition
        return builder
    }
}
