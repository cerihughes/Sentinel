import SceneKit

class NodePositioning: NSObject {
    private let gridWidth: Float
    private let gridDepth: Float
    let floorSize: Float

    init(gridWidth: Int, gridDepth: Int, floorSize: Float) {
        self.gridWidth = Float(gridWidth)
        self.gridDepth = Float(gridDepth)
        self.floorSize = floorSize
        
        super.init()
    }

    func calculateTerrainPosition(x: Int, y: Float, z: Int) -> SCNVector3 {
        let height: Float = 1.0
        return SCNVector3Make((Float(x) - (gridWidth / 2.0)) * floorSize,
                              (y - (height / 2.0)) * floorSize,
                              (Float(z) - (gridDepth / 2.0)) * floorSize)
    }

    func calculateObjectPosition() -> SCNVector3 {
        return SCNVector3Make(0.0,
                              0.5 * floorSize,
                              0.0)
    }
}
