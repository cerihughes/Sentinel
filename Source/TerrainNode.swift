import SceneKit

let terrainNodeName = "terrainNodeName"

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

    var opponentNodes: [OpponentNode] {
        var nodes: [OpponentNode] = []
        if let sentinelNode = sentinelNode {
            nodes.append(sentinelNode)
        }
        nodes.append(contentsOf: sentryNodes)
        return nodes
    }
}
