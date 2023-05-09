#if DEBUG
import SceneKit

/// A test scenario to make sure multiple opponents don't try and absorb the same objects at the same time.
class MultipleOpponentAbsorbViewModel {
    let world = SpaceWorld()
    let initialCameraNode: SCNNode
    let opponentsOperations: OpponentsOperations
    private let terrainOperations: TerrainOperations
    private let initialTrees: Int
    private let rocksCreated: Int
    private var absorbed = 0

    init() {
        let level = 45
        let levelConfiguration = DefaultLevelConfiguration(level: level)
        let terrainGenerator = DefaultTerrainGenerator(gridConfiguration: levelConfiguration)
        let materialFactory = DefaultMaterialFactory(level: level)
        var grid = terrainGenerator.generate()
        initialTrees = grid.treePositions.count
        rocksCreated = grid.addRockNodesToLowestLevel()

        let nodeMap = NodeMap()
        let nodePositioning = levelConfiguration.createNodePositioning()
        let nodeFactory = NodeFactory(
            nodePositioning: nodePositioning,
            detectionRadius: levelConfiguration.opponentDetectionRadius * .floorSize,
            materialFactory: materialFactory
        )
        let terrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: nodeMap)
        world.set(terrainNode: terrainNode)

        initialCameraNode = nodeFactory.createSynthoidNode(height: 0, viewingAngle: 0.0).cameraNode
        initialCameraNode.position = SCNVector3Make(50.0, 300, 250)
        initialCameraNode.look(at: terrainNode.worldPosition)

        terrainNode.addChildNode(initialCameraNode)

        let nodeManipulator = NodeManipulator(
            terrainNode: terrainNode,
            nodeMap: nodeMap,
            nodeFactory: nodeFactory,
            animatable: true
        )
        nodeManipulator.makeSynthoidCurrent(at: grid.startPosition)

        terrainOperations = TerrainOperations(grid: grid, nodeManipulator: nodeManipulator)
        opponentsOperations = .init(
            opponentConfiguration: levelConfiguration,
            terrainOperations: terrainOperations
        )

        opponentsOperations.delegate = self
        opponentsOperations.timeMachine.start()
    }
}

extension MultipleOpponentAbsorbViewModel: OpponentsOperationsDelegate {
    func opponentsOperationsDidAbsorb(_: OpponentsOperations) {
        absorbed += 1

        if absorbed == expectedAbsorptions {
            assert(terrainOperations.grid.allRockPositions().isEmpty)
            assert(terrainOperations.grid.treePositions.count == expectedTrees)
        }
    }

    private var expectedAbsorptions: Int {
        rocksCreated
    }

    private var expectedTrees: Int {
        (rocksCreated * 2) + initialTrees
    }

    func opponentsOperationsDidDepleteEnergy(_: OpponentsOperations) -> Bool {
        false // Don't create trees from player energy
    }

    func opponentsOperations(_: OpponentsOperations, didDetectOpponent cameraNode: SCNNode) {}
    func opponentsOperations(_: OpponentsOperations, didEndDetectOpponent cameraNode: SCNNode) {}
}

private extension Grid {
    mutating func addRockNodesToLowestLevel() -> Int {
        let points = emptyFloorPieces()
            .filter { Int($0.level) > 1 }
            .map { $0.point }
        points.forEach { addRock(at: $0) }
        return points.count
    }
}
#endif
