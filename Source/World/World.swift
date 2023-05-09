import SceneKit

protocol World {
    func buildWorld(in scene: SCNScene, around terrainNode: TerrainNode)
}
