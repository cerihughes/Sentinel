#if DEBUG
import SceneKit

class StagingAreaViewModel {
    let built: WorldBuilder.Built

    init(level: Int = 4) {
        let worldBuilder = WorldBuilder.createDefault(level: level)
        built = worldBuilder.build()
        _ = built.playerOperations.enterScene()
        built.timeMachine.start()
    }
}
#endif
