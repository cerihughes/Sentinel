import SceneKit

class StagingAreaViewModel {
    let world = SpaceWorld()
    let initialCameraNode: SCNNode
    let opponentsOperations: OpponentsOperations

    init(level: Int = 4) {
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
        initialCameraNode.position = SCNVector3Make(0.0, 250, 275)
        initialCameraNode.look(at: terrainNode.position)

        terrainNode.addChildNode(initialCameraNode)

        let nodeManipulator = NodeManipulator(terrainNode: terrainNode, nodeMap: nodeMap, nodeFactory: nodeFactory)
        nodeManipulator.makeSynthoidCurrent(at: grid.startPosition)

        let terrainOperations = TerrainOperations(grid: grid, nodeManipulator: nodeManipulator)
        opponentsOperations = .init(
            opponentConfiguration: levelConfiguration,
            terrainOperations: terrainOperations
        )
        opponentsOperations.timeMachine.start()
    }
}

private extension Grid {
    mutating func addRockNodesToLowestLevel() {
        rockPositions = emptyFloorPieces()
            .filter { Int($0.level) > 3 }
            .map { $0.point }
    }
}
