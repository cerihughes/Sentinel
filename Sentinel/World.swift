import SceneKit

protocol World {
    var playerScene: SCNScene {get}
    var opponentScene: SCNScene {get}
    var initialCameraNode: SCNNode {get}

    func set(playerTerrainNode: TerrainNode, opponentTerrainNode: TerrainNode)
}
