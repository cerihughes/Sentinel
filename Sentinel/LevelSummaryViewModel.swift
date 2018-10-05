import SceneKit

class LevelSummaryViewModel: NSObject {
    let world: World
    let terrainViewModel: TerrainViewModel
    let level: Int

    init(levelConfiguration: LevelConfiguration, nodeFactory: NodeFactory, world: World) {
        self.world = world
        self.level = levelConfiguration.level

        let tg = TerrainGenerator()
        let grid = tg.generate(levelConfiguration: levelConfiguration)

        let nodeMap = NodeMap()
        let terrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: nodeMap)
        world.set(terrainNode: terrainNode)

        let nodeManipulator = NodeManipulator(terrainNode: terrainNode, nodeMap: nodeMap, nodeFactory: nodeFactory)

        self.terrainViewModel = TerrainViewModel(grid: grid, nodeManipulator: nodeManipulator)

        super.init()

        self.startAnimations()
    }

    func startAnimations() {
        let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat(radiansInCircle), z: 0, duration: 3.0)
        let repeatedAction = SCNAction.repeatForever(rotationAction)
        for opponentNode in terrainViewModel.nodeManipulator.terrainNode.opponentNodes {
            opponentNode.runAction(repeatedAction)
        }
    }
}
