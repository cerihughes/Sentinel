import SceneKit

let treeNodeName = "treeNodeName"

class TreeNode: SCNNode, PlaceableNode, DetectableNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init() {
        super.init()

        let width = CGFloat.floorSize
        let height = width * 1.5
        let maxRadius = width / 3.0

        let trunkHeight: CGFloat = height * 3.0 / 10.0
        let trunkRadius: CGFloat = maxRadius * 0.2

        let trunkNode = SCNNode(geometry: SCNCylinder(radius: trunkRadius, height: trunkHeight))
        trunkNode.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
        trunkNode.position.y = Float(trunkHeight / 2.0)
        addChildNode(trunkNode)

        let initialLeafRadius = maxRadius
        let leafHeight: CGFloat = height - trunkHeight
        let numberOfLevels = 4
        let sectionHeight = leafHeight / CGFloat(numberOfLevels)
        var y = Float(trunkHeight + (sectionHeight / 2.0))

        let radiusDelta = initialLeafRadius / CGFloat(numberOfLevels + 1)
        for i in 0 ..< numberOfLevels {
            let bottomRadius = initialLeafRadius - (radiusDelta * CGFloat(i))
            let topRadius = bottomRadius - (radiusDelta * 2.0)
            let leavesNode = SCNNode(geometry: SCNCone(
                topRadius: topRadius,
                bottomRadius: bottomRadius,
                height: sectionHeight
            ))
            leavesNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
            leavesNode.position.y = y

            y += Float(sectionHeight)

            addChildNode(leavesNode)
        }

        name = treeNodeName
        categoryBitMask |= interactiveNodeBitMask
    }

    var floorNode: FloorNode? {
        return parent as? FloorNode
    }

    var detectionNodes: [SCNNode] {
        return childNodes.compactMap { $0.geometry is SCNCone ? $0 : nil }
    }
}
