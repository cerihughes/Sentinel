import SceneKit
import SpriteKit

class GameViewModel {
    let world: World
    let terrainOperations: TerrainOperations
    let playerOperations: PlayerOperations
    let opponentsOperations: OpponentsOperations
    let gameScore: GameScore
    var levelScore = LevelScore()

    init(levelConfiguration: LevelConfiguration, gameScore: GameScore, nodeFactory: NodeFactory, world: World) {
        self.world = world
        self.gameScore = gameScore

        let tg = TerrainGenerator()
        let grid = tg.generate(levelConfiguration: levelConfiguration)

        let nodeMap = NodeMap()
        let terrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: nodeMap)
        world.set(terrainNode: terrainNode)

        let nodeManipulator = NodeManipulator(terrainNode: terrainNode, nodeMap: nodeMap, nodeFactory: nodeFactory)

        terrainOperations = TerrainOperations(grid: grid, nodeManipulator: nodeManipulator)
        playerOperations = PlayerOperations(levelConfiguration: levelConfiguration,
                                            terrainOperations: terrainOperations,
                                            initialCameraNode: world.initialCameraNode)
        opponentsOperations = OpponentsOperations(levelConfiguration: levelConfiguration, terrainOperations: terrainOperations)
    }
}
