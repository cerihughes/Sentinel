import SceneKit

let sentinelNodeName = "sentinelNodeName"
let sentryNodeName = "sentryNodeName"

class OpponentNode: SCNNode, PlaceableNode, ViewingNode {
    override fileprivate init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    fileprivate init(colour: UIColor) {
        super.init()

        let material = SCNMaterial()
        material.diffuse.contents = colour

        let segments = 3
        var y: Float = 0.0
        for i in 0 ..< segments {
            let radius = (.floorSize / 2.0) - Float(i)
            let sphere = SCNSphere(radius: CGFloat(radius))
            sphere.firstMaterial = material
            let sphereNode = SCNNode(geometry: sphere)
            y += radius
            sphereNode.position.y = y
            y += 5.0 / Float(segments - 1)
            addChildNode(sphereNode)
        }

        let eyeNode = EyeNode()
        eyeNode.rotation = SCNVector4Make(1.0, 0.0, 0.0, Float.pi / -6.0)
        eyeNode.position.z = .floorSize / -5.0
        eyeNode.position.y = y
        addChildNode(eyeNode)
    }

    var floorNode: FloorNode? {
        return parent as? FloorNode
    }

    var cameraNode: SCNNode {
        return childNode(withName: cameraNodeName, recursively: true)!
    }

    func rotate(by radians: Float) {
        let fromValue = rotation.w
        let toValue = fromValue + radians
        SCNTransaction.begin()
        SCNTransaction.animationDuration = .animationDuration
        rotation.w = toValue
        SCNTransaction.commit()
    }
}

class SentinelNode: OpponentNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init() {
        super.init(colour: .blue)

        name = sentinelNodeName
        categoryBitMask |= interactiveNodeBitMask
    }
}

class SentryNode: OpponentNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init() {
        super.init(colour: .green)

        name = sentryNodeName
        categoryBitMask |= interactiveNodeBitMask
    }
}
