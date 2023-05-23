import SceneKit

class NodePositioning {
    private let gridWidth: Float
    private let gridDepth: Float

    init(gridWidth: Int, gridDepth: Int) {
        self.gridWidth = Float(gridWidth)
        self.gridDepth = Float(gridDepth)
    }

    func calculateTerrainPosition(x: Int, y: Float, z: Int) -> SCNVector3 {
        let height: Float = 1.0
        return SCNVector3Make(
            (Float(x) - (gridWidth / 2.0)) * .floorSize,
            (y - (height / 2.0)) * .floorSize,
            (Float(z) - (gridDepth / 2.0)) * .floorSize
        )
    }

    func calculateObjectPosition(height: Int = 0) -> SCNVector3 {
        let heightOffset = Float(height) * 0.5 * .floorSize
        return SCNVector3Make(
            0.0,
            (0.5 * .floorSize) + heightOffset,
            0.0
        )
    }
}

extension Grid {
    func createNodePositioning() -> NodePositioning {
        .init(gridWidth: width, gridDepth: depth)
    }
}
