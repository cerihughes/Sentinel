import SceneKit

let slopeNodeName = "slopeNodeName"

class SlopeNode: SCNNode {
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(colour: UIColor) {
        super.init()

        geometry = createGeometry(colour: colour)
        name = slopeNodeName
        categoryBitMask |= noninteractiveBlockingNodeBitMask
    }

    func createGeometry(colour: UIColor) -> SCNGeometry {
        let halfSide = CGFloat.floorSize / 2.0

        let material = SCNMaterial()
        material.diffuse.contents = colour
        material.locksAmbientWithDiffuse = true

        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: -halfSide, y: -halfSide))
        bezierPath.addLine(to: CGPoint(x: -halfSide, y: halfSide))
        bezierPath.addLine(to: CGPoint(x: halfSide, y: -halfSide))
        bezierPath.close()
        let slope = SCNShape(path: bezierPath, extrusionDepth: .floorSize)
        slope.firstMaterial = material

        return slope
    }
}
