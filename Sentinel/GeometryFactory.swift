import SceneKit

class GeometryFactory: NSObject {

    func createCube(size: Float, colour: UIColor) -> SCNGeometry {
        let material = SCNMaterial()
        material.diffuse.contents = colour
        material.locksAmbientWithDiffuse = true

        let sideLength = CGFloat(size)
        let box = SCNBox(width: CGFloat(sideLength),
                         height: CGFloat(sideLength),
                         length: CGFloat(sideLength),
                         chamferRadius: 0.0)
        box.firstMaterial = material

        return box
    }

    func createWedge(size: Float, colour: UIColor) -> SCNGeometry {
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

