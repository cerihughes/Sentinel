import SceneKit

class LevelSummaryViewModel: NSObject {
    let world: World
    let terrainViewModel: TerrainViewModel

    init(levelConfiguration: LevelConfiguration, nodeFactory: NodeFactory, world: World) {
        self.world = world

        let tg = TerrainGenerator()
        let grid = tg.generate(levelConfiguration: levelConfiguration)

        let nodeMap = NodeMap()
        let terrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: nodeMap)
        world.set(terrainNode: terrainNode)

        let nodeManipulator = NodeManipulator(terrainNode: terrainNode, nodeMap: nodeMap, nodeFactory: nodeFactory)

        self.terrainViewModel = TerrainViewModel(grid: grid, nodeManipulator: nodeManipulator)

        super.init()
    }
}
