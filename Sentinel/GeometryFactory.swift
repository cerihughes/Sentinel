import SceneKit

class GeometryFactory: NSObject {
    let size: Float

    init(size: Float) {
        self.size = size

        super.init()
    }

    func createCube(colour: UIColor) -> SCNGeometry {
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

    func createRockSegment(colour: UIColor, extrusionDepth: Float) -> SCNGeometry {
        let unit = CGFloat(10.0 / size)

        let material = SCNMaterial()
        material.diffuse.contents = colour
        material.locksAmbientWithDiffuse = true

        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: -3.0 * unit, y: 2.0 * unit))
        bezierPath.addLine(to: CGPoint(x: 1.0 * unit, y: 4.0 * unit))
        bezierPath.addLine(to: CGPoint(x: 4.0 * unit, y: 2.0 * unit))
        bezierPath.addLine(to: CGPoint(x: 2.0 * unit, y: -1.0 * unit))
        bezierPath.addLine(to: CGPoint(x: 2.0 * unit, y: -4.0 * unit))
        bezierPath.addLine(to: CGPoint(x: -4.0 * unit, y: -2.0 * unit))
        bezierPath.close()
        let rock = SCNShape(path: bezierPath, extrusionDepth: CGFloat(extrusionDepth))
        rock.firstMaterial = material

        return rock
    }
}

