import SceneKit

let slopeNodeName = "slopeNodeName"

class SlopeNode: SCNNode {
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(floorSize: Float, colour: UIColor) {
        super.init()

        geometry = createGeometry(floorSize: floorSize, colour: colour)
        name = slopeNodeName
        categoryBitMask |= noninteractiveNodeBitMask
    }

    func createGeometry(floorSize: Float, colour: UIColor) -> SCNGeometry {
        let halfSide = CGFloat(floorSize / 2.0)

        let material = SCNMaterial()
        material.diffuse.contents = colour
        material.locksAmbientWithDiffuse = true

        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: -halfSide, y: -halfSide))
        bezierPath.addLine(to: CGPoint(x: -halfSide, y: halfSide))
        bezierPath.addLine(to: CGPoint(x: halfSide, y: -halfSide))
        bezierPath.close()
        let slope = SCNShape(path: bezierPath, extrusionDepth: CGFloat(floorSize))
        slope.firstMaterial = material

        return slope
    }
}
