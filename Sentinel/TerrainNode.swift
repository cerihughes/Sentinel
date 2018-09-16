import SceneKit

class TerrainNode: SCNNode {
    override init() {
        super.init()
        name = terrainNodeName
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var sentinelNode: SentinelNode? {
        return childNode(withName: sentinelNodeName, recursively: true) as? SentinelNode
    }
}
