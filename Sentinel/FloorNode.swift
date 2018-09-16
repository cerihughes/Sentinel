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
        categoryBitMask = InteractableNodeType.floor.rawValue
    }

    var treeNode: TreeNode? {
        get {
            return get(name: treeNodeName) as? TreeNode
        }
        set {
            set(instance: newValue, name: treeNodeName)
        }
    }

    var synthoidNode: SCNNode? {
        get {
            return get(name: synthoidNodeName)
        }
        set {
            set(instance: newValue, name: synthoidNodeName)
        }
    }

    var sentinelNode: SCNNode? {
        get {
            return get(name: sentinelNodeName)
        }
        set {
            set(instance: newValue, name: sentinelNodeName)
        }
    }

    var sentryNode: SCNNode? {
        get {
            return get(name: sentryNodeName)
        }
        set {
            set(instance: newValue, name: sentryNodeName)
        }
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

    func rockNodes() -> [RockNode] {
        let filtered = childNodes.filter( { $0.name != nil && $0.name! == rockNodeName } )
        return filtered.compactMap( { $0 as? RockNode } )
    }

    func add(rockNode: RockNode) {
        addChildNode(rockNode)
    }

    func removeLastRockNode() -> RockNode? {
        guard let last = rockNodes().last else {
            return nil
        }

        last.removeFromParentNode()
        return last
    }
}
