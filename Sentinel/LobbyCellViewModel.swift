import SceneKit
import UIKit

class LobbyCellViewModel: NSObject {
    let levelConfiguration: LevelConfiguration
    let world: World

    private let grid: Grid
    private let timeMachine = TimeMachine()
    private let nodeManipulator: NodeManipulator

    init(levelConfiguration: LevelConfiguration, nodeFactory: NodeFactory, world: World) {
        self.levelConfiguration = levelConfiguration
        self.world = world

        let tg = TerrainGenerator()
        self.grid = tg.generate(levelConfiguration: levelConfiguration)

        let nodeMap = NodeMap()
        let terrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: nodeMap)
        world.set(terrainNode: terrainNode)

        self.nodeManipulator = NodeManipulator(terrainNode: terrainNode, nodeMap: nodeMap, nodeFactory: nodeFactory)

        super.init()
    }
}
