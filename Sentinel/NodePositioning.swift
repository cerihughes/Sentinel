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

    func calculatePosition(x: Int, y: Float, z: Int) -> SCNVector3 {
        return SCNVector3Make((Float(x) - (gridWidth / 2.0)) * Float(sideLength),
                              y * Float(sideLength),
                              (Float(z) - (gridDepth / 2.0)) * Float(sideLength))
    }
}
