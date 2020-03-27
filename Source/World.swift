import SceneKit

protocol World {
    var scene: SCNScene { get }
    var initialCameraNode: SCNNode { get }

    func set(terrainNode: TerrainNode)
}
