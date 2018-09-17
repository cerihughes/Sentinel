import SceneKit

class FloorNode: SCNNode {
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(floorSize: Float, colour: UIColor) {
        super.init()

        let material = SCNMaterial()
        material.diffuse.contents = colour
        material.locksAmbientWithDiffuse = true

        let sideLength = CGFloat(floorSize)
        let box = SCNBox(width: CGFloat(sideLength),
                         height: CGFloat(sideLength),
                         length: CGFloat(sideLength),
                         chamferRadius: 0.0)
        box.firstMaterial = material

        geometry = box
        name = floorNodeName
        categoryBitMask = interactiveNodeType.floor.rawValue
    }

    var treeNode: TreeNode? {
        get {
            return get(name: treeNodeName) as? TreeNode
        }
        set {
            set(instance: newValue, name: treeNodeName)
        }
    }

    var synthoidNode: SynthoidNode? {
        get {
            return get(name: synthoidNodeName) as? SynthoidNode
        }
        set {
            set(instance: newValue, name: synthoidNodeName)
        }
    }

    var sentinelNode: SentinelNode? {
        get {
            return get(name: sentinelNodeName) as? SentinelNode
        }
        set {
            set(instance: newValue, name: sentinelNodeName)
        }
    }

    var sentryNode: SentryNode? {
        get {
            return get(name: sentryNodeName) as? SentryNode
        }
        set {
            set(instance: newValue, name: sentryNodeName)
        }
    }

    var rockNodes: [RockNode] {
        return childNodes.compactMap { $0 as? RockNode }
    }

    private func get(name: String) -> SCNNode? {
        return childNode(withName: name, recursively: false)
    }

    private func set(instance: SCNNode?, name: String) {
        _ = remove(name: name)
        if let node = instance {
            addChildNode(node)
        }
    }

    private func remove(name: String) -> SCNNode? {
        guard let existing = get(name: name) else {
            return nil
        }

        existing.removeFromParentNode()
        return existing
    }

    func add(rockNode: RockNode) {
        addChildNode(rockNode)
    }

    func removeLastRockNode() -> RockNode? {
        guard let last = rockNodes.last else {
            return nil
        }

        last.removeFromParentNode()
        return last
    }

    var topmostNode: (SCNNode&PlaceableNode)? {
        return treeNode ?? sentinelNode ?? sentryNode ?? synthoidNode ?? rockNodes.last
    }
}
