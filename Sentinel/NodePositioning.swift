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

    func calculatePosition(x: Int, y: Int, z: Int, height: Int = 1) -> SCNVector3 {
        let heightf = Float(height)
        return SCNVector3Make((Float(x) - (gridWidth / 2.0)) * sideLength,
                              (Float(y) - (heightf / 2.0)) * sideLength,
                              (Float(z) - (gridDepth / 2.0)) * sideLength)
    }
}
