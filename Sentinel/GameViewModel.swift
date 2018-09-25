import SceneKit
import SpriteKit

class GameViewModel: NSObject {
    let world: World

    let terrainViewModel: TerrainViewModel
    let playerViewModel: PlayerViewModel
    let opponentsViewModel: OpponentsViewModel

    private let nodeManipulator: NodeManipulator

    init(levelConfiguration: LevelConfiguration, nodeFactory: NodeFactory, world: World) {
        self.world = world

        let tg = TerrainGenerator()
        let grid = tg.generate(levelConfiguration: levelConfiguration)

        let nodeMap = NodeMap()
        let terrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: nodeMap)
        world.set(terrainNode: terrainNode)

        self.nodeManipulator = NodeManipulator(terrainNode: terrainNode, nodeMap: nodeMap, nodeFactory: nodeFactory)

        self.terrainViewModel = TerrainViewModel(grid: grid, nodeManipulator: nodeManipulator)
        self.playerViewModel = PlayerViewModel(levelConfiguration: levelConfiguration, terrainViewModel: terrainViewModel, initialCameraNode: world.initialCameraNode)
        self.opponentsViewModel = OpponentsViewModel(levelConfiguration: levelConfiguration, terrainViewModel: terrainViewModel)

        super.init()
    }

    func cameraNode(for viewer: Viewer) -> SCNNode? {
        if let viewingNode = nodeManipulator.viewingNode(for: viewer) {
            return viewingNode.cameraNode
        }
        return nil
    }
}
