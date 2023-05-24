import SceneKit

let floorNodeName = "floorNodeName"

class FloorNode: SCNNode {
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(colour: UIColor) {
        super.init()

        let material = SCNMaterial()
        material.diffuse.contents = colour
        material.locksAmbientWithDiffuse = true

        let sideLength = CGFloat.floorSize
        let box = SCNBox(width: CGFloat(sideLength),
                         height: CGFloat(sideLength),
                         length: CGFloat(sideLength),
                         chamferRadius: 0.0)
        box.firstMaterial = material

        geometry = box
        name = floorNodeName
        categoryBitMask |= interactiveNodeBitMask
    }

    var treeNode: TreeNode? {
        get {
            get(name: treeNodeName) as? TreeNode
        }
        set {
            set(instance: newValue, name: treeNodeName)
        }
    }

    var synthoidNode: SynthoidNode? {
        get {
            get(name: synthoidNodeName) as? SynthoidNode
        }
        set {
            set(instance: newValue, name: synthoidNodeName)
        }
    }

    var sentinelNode: SentinelNode? {
        get {
            get(name: sentinelNodeName) as? SentinelNode
        }
        set {
            set(instance: newValue, name: sentinelNodeName)
        }
    }

    var sentryNode: SentryNode? {
        get {
            get(name: sentryNodeName) as? SentryNode
        }
        set {
            set(instance: newValue, name: sentryNodeName)
        }
    }

    var rockNodes: [RockNode] {
        childNodes.compactMap { $0 as? RockNode }
    }

    func get(name: String) -> SCNNode? {
        childNode(withName: name, recursively: false)
    }

    func set(instance: SCNNode?, name: String) {
        remove(name: name)
        if let node = instance {
            addChildNode(node)
        }
    }

    private func remove(name: String) {
        get(name: name)?.removeFromParentNode()
    }

    func add(rockNode: RockNode) {
        addChildNode(rockNode)
    }

    var topmostNode: PlaceableSCNNode? {
        treeNode ?? sentinelNode ?? sentryNode ?? synthoidNode ?? rockNodes.last
    }
}
