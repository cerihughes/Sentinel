import SceneKit
@testable import Sentinel

class MockWorld: World {
    var terrainNode: TerrainNode?

    var scene = SCNScene()
    var initialCameraNode = SCNNode()

    func set(terrainNode: TerrainNode) {
        self.terrainNode = terrainNode
    }
}
