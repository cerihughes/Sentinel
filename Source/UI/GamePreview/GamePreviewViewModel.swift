import SceneKit

class GamePreviewViewModel {
    let level: Int
    private let terrain: WorldBuilder.Terrain

    var scene: SCNScene { terrain.scene }
    var cameraNode: SCNNode { terrain.initialCameraNode }

    init(level: Int, worldBuilder: WorldBuilder) {
        self.level = level
        terrain = worldBuilder.buildTerrain()
    }

    func startAnimations() {
        let rotationAction = SCNAction.rotateBy(x: 0, y: .radiansInCircle, z: 0, duration: 3.0)
        for opponentNode in terrain.terrainNode.opponentNodes {
            opponentNode.runAction(.repeatForever(rotationAction))
        }
    }

    func stopAnimations() {
        for opponentNode in terrain.terrainOperations.nodeManipulator.terrainNode.opponentNodes {
            opponentNode.removeAllActions()
        }
    }
}
