import SceneKit

struct WorldBuilder {
    struct Built {
        let grid: Grid
        let nodeMap: NodeMap
        let nodeManipulator: NodeManipulator
        let nodeFactory: NodeFactory
        let terrainNode: TerrainNode
        let terrainOperations: TerrainOperations
        let initialCameraNode: SCNNode
        let synthoidEnergy: SynthoidEnergy
        let playerOperations: PlayerOperations
        let opponentsOperations: OpponentsOperations
    }
    let levelConfiguration: LevelConfiguration
    let terrainGenerator: TerrainGenerator
    let materialFactory: MaterialFactory
    let world: World

    func build() -> Built {
        let grid = terrainGenerator.generate()
        let nodeMap = NodeMap()
        let nodePositioning = NodePositioning(gridWidth: levelConfiguration.gridWidth,
                                              gridDepth: levelConfiguration.gridDepth,
                                              floorSize: floorSize)
        let nodeFactory = NodeFactory(nodePositioning: nodePositioning,
                                      detectionRadius: levelConfiguration.opponentDetectionRadius * floorSize,
                                      materialFactory: materialFactory)
        let terrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: nodeMap)
        world.set(terrainNode: terrainNode)

        let initialCameraNode = nodeFactory.createSynthoidNode(height: 0, viewingAngle: 0.0).cameraNode
        initialCameraNode.position = SCNVector3Make(0.0, 250, 275)
        initialCameraNode.look(at: terrainNode.position)

        terrainNode.addChildNode(initialCameraNode)

        let nodeManipulator = NodeManipulator(terrainNode: terrainNode, nodeMap: nodeMap, nodeFactory: nodeFactory)
        let terrainOperations = TerrainOperations(grid: grid, nodeManipulator: nodeManipulator)
        let synthoidEnergy = SynthoidEnergyMonitor()
        return .init(
            grid: grid,
            nodeMap: nodeMap,
            nodeManipulator: nodeManipulator,
            nodeFactory: nodeFactory,
            terrainNode: terrainNode,
            terrainOperations: terrainOperations,
            initialCameraNode: initialCameraNode,
            synthoidEnergy: synthoidEnergy,
            playerOperations: .init(
                terrainOperations: terrainOperations,
                synthoidEnergy: synthoidEnergy,
                initialCameraNode: initialCameraNode
            ),
            opponentsOperations: .init(opponentConfiguration: levelConfiguration, terrainOperations: terrainOperations)
        )
    }
}

extension WorldBuilder {
    static func createDefault(level: Int, world: World = SpaceWorld()) -> WorldBuilder {
        let levelConfiguration = DefaultLevelConfiguration(level: level)
        return .init(
            levelConfiguration: levelConfiguration,
            terrainGenerator: DefaultTerrainGenerator(gridConfiguration: levelConfiguration),
            materialFactory: DefaultMaterialFactory(level: level),
            world: world
        )
    }
}
