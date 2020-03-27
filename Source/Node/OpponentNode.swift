import SceneKit

let sentinelNodeName = "sentinelNodeName"
let sentryNodeName = "sentryNodeName"

class OpponentNode: SCNNode, PlaceableNode, ViewingNode {
    fileprivate override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    fileprivate init(floorSize: Float, detectionRadius: Float, colour: UIColor, options: [NodeFactoryOption]) {
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

        let eyeNode = EyeNode(floorSize: floorSize, detectionRadius: detectionRadius, options: options)
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
        return allTrees.filter { $0.floorNode != nil && !$0.floorNode!.rockNodes.isEmpty } // only return trees that have rocks under them
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
        let interactiveNodes = Set(frustrumNodes.compactMap { $0.findInteractiveParent()?.node })
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

            let options: [String: Any] = [SCNHitTestOption.searchMode.rawValue: SCNHitTestSearchMode.all.rawValue]
            let hits = worldNode.hitTestWithSegment(from: startPosition, to: endPosition, options: options)
            for hit in hits {
                if let placeableHit = hit.node.firstPlaceableParent() as? SCNNode {
                    if placeableHit == otherNode {
                        return true
                    }
                }
            }
        }
        return false
    }
}

class SentinelNode: OpponentNode {
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(floorSize: Float, detectionRadius: Float, options: [NodeFactoryOption]) {
        super.init(floorSize: floorSize, detectionRadius: detectionRadius, colour: .blue, options: options)

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

    init(floorSize: Float, detectionRadius: Float, options: [NodeFactoryOption]) {
        super.init(floorSize: floorSize, detectionRadius: detectionRadius, colour: .green, options: options)

        name = sentryNodeName
        categoryBitMask |= interactiveNodeBitMask
    }
}
