import SceneKit

class LevelSummaryViewModel {
    let level: Int
    let worldBuilder: WorldBuilder
    let built: WorldBuilder.Built

    init(level: Int, worldBuilder: WorldBuilder) {
        self.level = level
        self.worldBuilder = worldBuilder
        built = worldBuilder.build()
    }

    func startAnimations() {
        let rotationAction = SCNAction.rotateBy(x: 0, y: .radiansInCircle, z: 0, duration: 3.0)
        for opponentNode in built.terrainNode.opponentNodes {
            opponentNode.runAction(.repeatForever(rotationAction))
        }
    }

    func stopAnimations() {
        for opponentNode in built.terrainOperations.nodeManipulator.terrainNode.opponentNodes {
            opponentNode.removeAllActions()
        }
    }
}
