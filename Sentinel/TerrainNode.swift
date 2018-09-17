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

    var sentryNodes: [SentryNode] {
        let floorNodes = childNodes.compactMap { $0 as? FloorNode }
        return floorNodes.compactMap { $0.sentryNode }
    }

    var oppositionNodes: [OppositionNode] {
        var nodes: [OppositionNode] = []
        if let sentinelNode = sentinelNode {
            nodes.append(sentinelNode)
        }
        nodes.append(contentsOf: sentryNodes)
        return nodes
    }

}
