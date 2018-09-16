import SceneKit

class GeometryFactory: NSObject {
    let size: Float

    init(size: Float) {
        self.size = size

        super.init()
    }

    func createWedge(colour: UIColor) -> SCNGeometry {
        let halfSide = CGFloat(size / 2.0)

        let material = SCNMaterial()
        material.diffuse.contents = colour
        material.locksAmbientWithDiffuse = true

        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: -halfSide, y: -halfSide))
        bezierPath.addLine(to: CGPoint(x: -halfSide, y: halfSide))
        bezierPath.addLine(to: CGPoint(x: halfSide, y: -halfSide))
        bezierPath.close()
        let wedge = SCNShape(path: bezierPath, extrusionDepth: CGFloat(size))
        wedge.firstMaterial = material

        return wedge
    }
}

