import SceneKit
import UIKit

class LobbyCellViewModel: NSObject {
    let levelConfiguration: LevelConfiguration
    let world: World

    private let grid: Grid
    private let timeMachine = TimeMachine()
    private let nodeManipulator: NodeOperations

    init(levelConfiguration: LevelConfiguration, nodeFactory: NodeFactory, world: World) {
        self.levelConfiguration = levelConfiguration
        self.world = world

        let tg = TerrainGenerator()
        self.grid = tg.generate(levelConfiguration: levelConfiguration)

        let playerNodeMap = NodeMap()
        let playerTerrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: playerNodeMap)

        let opponentNodeMap = NodeMap()
        let opponentTerrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: opponentNodeMap)

        world.set(playerTerrainNode: playerTerrainNode, opponentTerrainNode: opponentTerrainNode)

        self.nodeManipulator = NodeManipulator(terrainNode: playerTerrainNode, nodeMap: playerNodeMap, nodeFactory: nodeFactory)

        super.init()
    }
}
