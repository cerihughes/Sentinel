import SceneKit

protocol World {
    var scene: SCNScene { get }
    func set(terrainNode: TerrainNode)
}
