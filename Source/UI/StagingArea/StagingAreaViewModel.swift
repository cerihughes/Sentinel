#if DEBUG
import SceneKit

class StagingAreaViewModel {
    private let terrain: WorldBuilder.Terrain
    private let operations: WorldBuilder.Operations

    var scene: SCNScene { terrain.scene }
    var cameraNode: SCNNode { terrain.initialCameraNode }
    var timeMachine: TimeMachine { operations.timeMachine }

    init(level: Int = 4) {
        let worldBuilder = WorldBuilder.createDefault(level: level)
        terrain = worldBuilder.buildTerrain()
        operations = terrain.createOperations()
        operations.playerOperations.enterScene()
        operations.timeMachine.start()
    }
}
#endif
