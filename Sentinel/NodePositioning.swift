import SceneKit

class NodePositioning: NSObject {
    let gridWidth: Float
    let gridDepth: Float
    let sideLength: Float

    init(gridWidth: Float, gridDepth: Float, sideLength: Float) {
        self.gridWidth = gridWidth
        self.gridDepth = gridDepth
        self.sideLength = sideLength
        
        super.init()
    }

    func calculateTerrainPosition(x: Int, y: Int, z: Int) -> SCNVector3 {
        let height: Float = 1.0
        return SCNVector3Make((Float(x) - (gridWidth / 2.0)) * sideLength,
                              (Float(y) - (height / 2.0)) * sideLength,
                              (Float(z) - (gridDepth / 2.0)) * sideLength)
    }

    func calculateObjectPosition(y: Int = 0, height: Int = 2) -> SCNVector3 {
        let stackHeight = Float(y * height) - 0.5 // 0.5 is half of the cube
        return SCNVector3Make(0.0,
                              (stackHeight + (Float(height) / 2.0)) * sideLength,
                              0.0)
    }
}
