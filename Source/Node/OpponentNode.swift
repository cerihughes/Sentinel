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

    fileprivate init(floorSize: Float, detectionRadius: Float, colour: UIColor) {
        super.init()

        let material = SCNMaterial()
        material.diffuse.contents = colour

        let segments = 3
        var y: Float = 0.0
        for i in 0 ..< segments {
            let fi = Float(i)
            let radius = (floorSize / 2.0) - fi
            let sphere = SCNSphere(radius: CGFloat(radius))
            sphere.firstMaterial = material
            let sphereNode = SCNNode(geometry: sphere)
            y += radius
            sphereNode.position.y = y
            y += 5.0 / Float(segments - 1)
            addChildNode(sphereNode)
        }

        let eyeNode = EyeNode(floorSize: floorSize, detectionRadius: detectionRadius)
        eyeNode.rotation = SCNVector4Make(1.0, 0.0, 0.0, Float.pi / -6.0)
        eyeNode.position.z = floorSize / -5.0
        eyeNode.position.y = y
        addChildNode(eyeNode)
    }

    var floorNode: FloorNode? {
        return parent as? FloorNode
    }

    var cameraNode: SCNNode {
        return childNode(withName: cameraNodeName, recursively: true)!
    }

    func visibleSynthoids(in renderer: SCNSceneRenderer) -> [SynthoidNode] {
        return visibleNodes(in: renderer, type: SynthoidNode.self)
    }

    func visibleRocks(in renderer: SCNSceneRenderer) -> [RockNode] {
        let allRocks = visibleNodes(in: renderer, type: RockNode.self)
        return allRocks.filter { $0.floorNode?.topmostNode == $0 } // only return rocks that have nothing on top of them
    }

    func visibleTreesOnRocks(in renderer: SCNSceneRenderer) -> [TreeNode] {
        let allTrees = visibleNodes(in: renderer, type: TreeNode.self)
        // only return trees that have rocks under them
        return allTrees.filter { $0.floorNode != nil && !$0.floorNode!.rockNodes.isEmpty }
    }

    func rotate(by radians: Float, duration: TimeInterval) {
        let fromValue = rotation.w
        let toValue = fromValue + radians
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        rotation.w = toValue
        SCNTransaction.commit()
    }
}

class SentinelNode: OpponentNode {
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(floorSize: Float, detectionRadius: Float) {
        super.init(floorSize: floorSize, detectionRadius: detectionRadius, colour: .blue)

        name = sentinelNodeName
        categoryBitMask |= interactiveNodeBitMask
    }
}

class SentryNode: OpponentNode {
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(floorSize: Float, detectionRadius: Float) {
        super.init(floorSize: floorSize, detectionRadius: detectionRadius, colour: .green)

        name = sentryNodeName
        categoryBitMask |= interactiveNodeBitMask
    }
}
