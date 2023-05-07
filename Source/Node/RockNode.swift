import SceneKit

let rockNodeName = "rockNodeName"

class RockNode: SCNNode, PlaceableNode, DetectableNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init() {
        super.init()

        let rockNode = SCNNode()
        let height = Float.floorSize / 2.0

        var sectionNode = RockSectionNode(
            position: SCNVector3Make(0, 0, height / 6.0),
            rotation: SCNVector4Make(0.0, 0.0, 1.0, Float.pi / 1.14)
        )
        rockNode.addChildNode(sectionNode)

        sectionNode = sectionNode.clone()
        sectionNode.position = SCNVector3Make(0, 0, height / 6.0 * 2.0)
        sectionNode.rotation = SCNVector4Make(0.2, 0.4, 0.4, -0.28)
        rockNode.addChildNode(sectionNode)

        sectionNode = sectionNode.clone()
        sectionNode.position = SCNVector3Make(0, 0, height / 6.0 * 3.0)
        sectionNode.rotation = SCNVector4Make(0.1, 0.1, 0.9, 0.18)
        rockNode.addChildNode(sectionNode)

        sectionNode = sectionNode.clone()
        sectionNode.position = SCNVector3Make(0, 0, height / 6.0 * 4.0)
        sectionNode.rotation = SCNVector4Make(0.6, 0.8, 0.0, -0.12)
        rockNode.addChildNode(sectionNode)

        sectionNode = sectionNode.clone()
        sectionNode.position = SCNVector3Make(0, 0, height / 6.0 * 5.0)
        sectionNode.rotation = SCNVector4Make(0.0, 0.0, 1.0, Float.pi / 1.54)
        rockNode.addChildNode(sectionNode)

        rockNode.rotation = SCNVector4Make(1.0, 0.0, 0.0, Float.pi / -2.0)

        name = rockNodeName
        categoryBitMask |= interactiveNodeBitMask
        addChildNode(rockNode)
    }

    var floorNode: FloorNode? {
        return parent as? FloorNode
    }

    var detectionNodes: [SCNNode] {
        return [self]
    }

    private class RockSectionNode: SCNNode {
        override init() {
            super.init()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

        init(position: SCNVector3, rotation: SCNVector4) {
            super.init()

            geometry = createRockGeometry(floorSize: .floorSize, extrusionDepth: .floorSize / 3.0, colour: .darkGray)
            self.position = position
            self.rotation = rotation
        }

        private func createRockGeometry(floorSize: Float, extrusionDepth: Float, colour: UIColor) -> SCNGeometry {
            let unit = CGFloat(10.0 / floorSize)

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
}
