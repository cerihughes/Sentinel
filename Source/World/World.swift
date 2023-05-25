import SceneKit

protocol World {
    func buildWorld(in scene: SCNScene, around terrainNode: TerrainNode)
}

class EmptyWorld: World {
    func buildWorld(in scene: SCNScene, around terrainNode: TerrainNode) {
        scene.rootNode.addChildNode(terrainNode)
    }
}
