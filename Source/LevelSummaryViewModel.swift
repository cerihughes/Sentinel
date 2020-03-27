import SceneKit

class LevelSummaryViewModel {
    let world: World
    let terrainOperations: TerrainOperations
    let level: Int

    init(levelConfiguration: LevelConfiguration, nodeFactory: NodeFactory, world: World) {
        self.world = world
        level = levelConfiguration.level

        let tg = TerrainGenerator()
        let grid = tg.generate(levelConfiguration: levelConfiguration)

        let nodeMap = NodeMap()
        let terrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: nodeMap)
        world.set(terrainNode: terrainNode)

        let nodeManipulator = NodeManipulator(terrainNode: terrainNode, nodeMap: nodeMap, nodeFactory: nodeFactory)

        terrainOperations = TerrainOperations(grid: grid, nodeManipulator: nodeManipulator)
    }

    func startAnimations() {
        let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat(radiansInCircle), z: 0, duration: 3.0)
        let repeatedAction = SCNAction.repeatForever(rotationAction)
        for opponentNode in terrainOperations.nodeManipulator.terrainNode.opponentNodes {
            opponentNode.runAction(repeatedAction)
        }
    }

    func stopAnimations() {
        for opponentNode in terrainOperations.nodeManipulator.terrainNode.opponentNodes {
            opponentNode.removeAllActions()
        }
    }
}
