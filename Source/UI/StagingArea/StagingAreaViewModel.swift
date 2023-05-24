#if DEBUG
import SceneKit

class StagingAreaViewModel {
    let terrain: WorldBuilder.Terrain
    let operations: WorldBuilder.Operations

    init(level: Int = 4) {
        let worldBuilder = WorldBuilder.createDefault(level: level)
        terrain = worldBuilder.buildTerrain()
        operations = terrain.createOperations()
        operations.playerOperations.enterScene()
        operations.timeMachine.start()
    }
}
#endif
