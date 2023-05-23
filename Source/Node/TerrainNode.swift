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

    var floorNodes: [FloorNode] {
        childNodes.compactMap { $0 as? FloorNode }
    }

    var slopeNodes: [SlopeNode] {
        childNodes.compactMap { $0 as? SlopeNode }
    }

    var sentinelNode: SentinelNode? {
        childNode(withName: sentinelNodeName, recursively: true) as? SentinelNode
    }

    var sentryNodes: [SentryNode] {
        floorNodes.compactMap { $0.sentryNode }
    }

    var opponentNodes: [OpponentNode] {
        ([sentinelNode] + sentryNodes)
            .compactMap { $0 }
    }
}
