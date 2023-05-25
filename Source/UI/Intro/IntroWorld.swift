import SceneKit

class IntroWorld: World {
    let sentinelNode = SentinelNode()

    init() {
        sentinelNode.position = SCNVector3(200.0, -1850, -875)
        sentinelNode.scale = SCNVector3(75, 75, 75)
    }

    func buildWorld(in scene: SCNScene, around terrainNode: TerrainNode) {
        scene.rootNode.addChildNode(sentinelNode)
        scene.rootNode.addChildNode(terrainNode)
    }
}
