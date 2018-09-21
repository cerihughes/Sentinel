import SceneKit

class OppositionNode: SCNNode, PlaceableNode, ViewingNode {
    fileprivate override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    fileprivate init(floorSize: Float, detectionRadius: Float, colour: UIColor) {
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
        camera.fieldOfView = 45.0
        camera.zFar = Double(detectionRadius)
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
        return allTrees.filter { $0.floorNode != nil && $0.floorNode!.rockNodes.count > 0 } // only return trees that have rocks under them
    }

    func rotate(by radians: Float, duration: TimeInterval) {
        let fromValue = rotation.w
        let toValue = fromValue + radians
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        rotation.w = toValue        
        SCNTransaction.commit()
    }

    private func visibleNodes<T: SCNNode>(in renderer: SCNSceneRenderer, type: T.Type) -> [T] {
        guard let scene = renderer.scene else {
            return []
        }

        let cameraPresentation = cameraNode.presentation
        let frustrumNodes = renderer.nodesInsideFrustum(of: cameraPresentation)
        let interactiveNodes = Set(frustrumNodes.compactMap { $0.firstInteractiveParent() })
        let compacted = interactiveNodes.compactMap { $0 as? T }
        return compacted.filter { self.hasLineOfSight(from: cameraPresentation, to: $0, in: scene) }
    }

    private func hasLineOfSight(from cameraPresentationNode: SCNNode, to otherNode: SCNNode, in scene: SCNScene) -> Bool {
        guard let otherDetectableNode = otherNode as? DetectableNode else {
            return false
        }

        let worldNode = scene.rootNode
        for otherDetectionNode in otherDetectableNode.detectionNodes {
            let detectionPresentationNode = otherDetectionNode.presentation
            let startPosition = worldNode.convertPosition(cameraPresentationNode.worldPosition, to: nil)
            let endPosition = worldNode.convertPosition(detectionPresentationNode.worldPosition, to: nil)

            let hits = worldNode.hitTestWithSegment(from: startPosition, to: endPosition, options: [:])
            if let first = hits.first,
                let placeableHit = first.node.firstPlaceableParent() as? SCNNode {
                if placeableHit == otherNode {
                    return true
                }
            }
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

    init(floorSize: Float, detectionRadius: Float) {
        super.init(floorSize: floorSize, detectionRadius: detectionRadius, colour: .blue)

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

    init(floorSize: Float, detectionRadius: Float) {
        super.init(floorSize: floorSize, detectionRadius: detectionRadius, colour: .green)

        name = sentryNodeName
        categoryBitMask = interactiveNodeType.sentry.rawValue
    }
}
