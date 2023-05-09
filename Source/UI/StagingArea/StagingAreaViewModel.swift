#if DEBUG
import SceneKit

class StagingAreaViewModel {
    let world = SpaceWorld()
    let initialCameraNode: SCNNode
    let opponentsOperations: OpponentsOperations

    init(level: Int = 4) {
        let levelConfiguration = DefaultLevelConfiguration(level: level)
        let terrainGenerator = DefaultTerrainGenerator(gridConfiguration: levelConfiguration)
        let materialFactory = DefaultMaterialFactory(level: level)
        let grid = terrainGenerator.generate()

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
        initialCameraNode.position = SCNVector3Make(50.0, 175, 150)
        initialCameraNode.look(at: terrainNode.sentinelNode!.worldPosition)

        terrainNode.addChildNode(initialCameraNode)

        let nodeManipulator = NodeManipulator(terrainNode: terrainNode, nodeFactory: nodeFactory, animatable: true)
        nodeManipulator.currentSynthoidNode = nodeMap.synthoidNode(at: grid.startPosition)

        let terrainOperations = TerrainOperations(grid: grid, nodeMap: nodeMap, nodeManipulator: nodeManipulator)
        opponentsOperations = .init(
            opponentConfiguration: levelConfiguration,
            terrainOperations: terrainOperations
        )
        opponentsOperations.timeMachine.start()
    }
}
#endif
