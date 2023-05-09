#if DEBUG
import SceneKit

class MultipleOpponentAbsorbViewModel {
    let world = SpaceWorld()
    let initialCameraNode: SCNNode
    let opponentsOperations: OpponentsOperations
    private var absorbed = 0

    init() {
        let level = 45
        let levelConfiguration = DefaultLevelConfiguration(level: level)
        let terrainGenerator = DefaultTerrainGenerator(gridConfiguration: levelConfiguration)
        let materialFactory = DefaultMaterialFactory(level: level)
        var grid = terrainGenerator.generate()
        grid.addRockNodesToLowestLevel()

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

        let terrainOperations = TerrainOperations(grid: grid, nodeManipulator: nodeManipulator)
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
    }

    func opponentsOperationsDidDepleteEnergy(_: OpponentsOperations) {}
    func opponentsOperations(_: OpponentsOperations, didDetectOpponent cameraNode: SCNNode) {}
    func opponentsOperations(_: OpponentsOperations, didEndDetectOpponent cameraNode: SCNNode) {}
}

private extension Grid {
    mutating func addRockNodesToLowestLevel() {
        let points = emptyFloorPieces()
            .filter { Int($0.level) > 1 }
            .map { $0.point }
        points.forEach {
            addRock(at: $0)
        }
    }
}
#endif
