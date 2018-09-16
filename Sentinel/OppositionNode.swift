import SceneKit

class OppositionNode: SCNNode, InteractiveNode {
    fileprivate override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    fileprivate init(floorSize: Float, colour: UIColor) {
        super.init()

        var material = SCNMaterial()
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

        material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        let width = CGFloat(floorSize / 3.0)
        let height = CGFloat(floorSize / 10.0)
        let box = SCNBox(width: width, height: height, length: height, chamferRadius: 0.2)
        box.firstMaterial = material
        let boxNode = SCNNode(geometry: box)
        boxNode.position.z = floorSize / 5.0
        boxNode.position.y = y
        let camera = SCNCamera()
        camera.zFar = 500.0
        let cameraNode = SCNNode()
        cameraNode.name = cameraNodeName
        cameraNode.camera = camera
        cameraNode.rotation = SCNVector4Make(0.0, 1.0, 0.25, Float.pi)
        cameraNode.position = SCNVector3Make(0.0, 0.0, floorSize / 10.0)

        boxNode.addChildNode(cameraNode)
        addChildNode(boxNode)
    }

    var floorNode: FloorNode? {
        return parent as? FloorNode
    }

    var cameraNode: SCNNode? {
        return childNode(withName: cameraNodeName, recursively: true)
    }

    func visibleSynthoids(in sceneRenderer: SCNSceneRenderer) -> [SynthoidNode] {
        return visibleNodes(in: sceneRenderer, type: SynthoidNode.self)
    }

    func visibleRocks(in sceneRenderer: SCNSceneRenderer) -> [RockNode] {
        return visibleNodes(in: sceneRenderer, type: RockNode.self)
    }

    private func visibleNodes<T: SCNNode>(in sceneRenderer: SCNSceneRenderer, type: T.Type) -> Array<T> {
        guard let scene = sceneRenderer.scene, let cameraNode = cameraNode else {
            return []
        }

        let cameraPresentation = cameraNode.presentation
        let frustrumNodes = sceneRenderer.nodesInsideFrustum(of: cameraPresentation)
        let compacted = frustrumNodes.compactMap { $0 as? T }
        return compacted.filter { self.hasLineOfSight(from: cameraPresentation, to: $0, in: scene) }
    }

    private func hasLineOfSight(from cameraPresentationNode: SCNNode, to otherNode: SCNNode, in scene: SCNScene) -> Bool {
        let worldNode = scene.rootNode
        let otherPresentationNode = otherNode.presentation
        let startPosition = worldNode.convertPosition(cameraPresentationNode.worldPosition, to: nil)
        let endPosition = worldNode.convertPosition(otherPresentationNode.worldPosition, to: nil)

        let hits = worldNode.hitTestWithSegment(from: startPosition, to: endPosition, options: [:])
        if let first = hits.first {
            return first.node == otherNode
        }
        return false
    }
}

class SentinelNode: OppositionNode {
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(floorSize: Float) {
        super.init(floorSize: floorSize, colour: .blue)

        name = sentinelNodeName
        categoryBitMask = interactiveNodeType.sentinel.rawValue
    }
}

class SentryNode: OppositionNode {
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(floorSize: Float) {
        super.init(floorSize: floorSize, colour: .green)

        name = sentryNodeName
        categoryBitMask = interactiveNodeType.sentry.rawValue
    }
}
