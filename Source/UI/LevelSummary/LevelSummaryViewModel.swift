import SceneKit

class LevelSummaryViewModel {
    let worldBuilder: WorldBuilder
    let built: WorldBuilder.Built

    init(worldBuilder: WorldBuilder) {
        self.worldBuilder = worldBuilder
        built = worldBuilder.build()
    }

    func startAnimations() {
        let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat(radiansInCircle), z: 0, duration: 3.0)
        let repeatedAction = SCNAction.repeatForever(rotationAction)
        for opponentNode in built.terrainOperations.nodeManipulator.terrainNode.opponentNodes {
            opponentNode.runAction(repeatedAction)
        }
    }

    func stopAnimations() {
        for opponentNode in built.terrainOperations.nodeManipulator.terrainNode.opponentNodes {
            opponentNode.removeAllActions()
        }
    }
}
