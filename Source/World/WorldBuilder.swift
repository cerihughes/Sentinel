import SceneKit

struct WorldBuilder {
    struct Built {
        let nodeMap: NodeMap
        let nodeManipulator: NodeManipulator
        let nodeFactory: NodeFactory
        let scene: SCNScene
        let terrainNode: TerrainNode
        let terrainOperations: TerrainOperations
        let initialCameraNode: SCNNode
        let synthoidEnergy: SynthoidEnergy
        let timeMachine: TimeMachine
        let playerOperations: PlayerOperations
        let opponentsOperations: OpponentsOperations
    }
    let levelConfiguration: LevelConfiguration
    let terrainGenerator: TerrainGenerator
    let materialFactory: MaterialFactory
    let world: World
    let animatable: Bool

    func build() -> Built {
        let grid = terrainGenerator.generate()
        let nodeMap = NodeMap()
        let nodePositioning = levelConfiguration.createNodePositioning()
        let nodeFactory = NodeFactory(
            nodePositioning: nodePositioning,
            detectionRadius: levelConfiguration.opponentDetectionRadius * .floorSize,
            materialFactory: materialFactory
        )
        let terrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: nodeMap)
        let scene = SCNScene()
        world.buildWorld(in: scene, around: terrainNode)

        let initialCameraNode = nodeFactory.createSynthoidNode(height: 0, viewingAngle: 0.0).cameraNode
        initialCameraNode.position = SCNVector3Make(0.0, 250, 275)
        initialCameraNode.look(at: terrainNode.position)

        terrainNode.addChildNode(initialCameraNode)

        let nodeManipulator = NodeManipulator(
            terrainNode: terrainNode,
            nodeFactory: nodeFactory,
            animatable: animatable
        )
        let terrainOperations = TerrainOperations(grid: grid, nodeMap: nodeMap, nodeManipulator: nodeManipulator)
        let synthoidEnergy = SynthoidEnergyMonitor()
        let timeMachine = TimeMachine()
        return .init(
            nodeMap: nodeMap,
            nodeManipulator: nodeManipulator,
            nodeFactory: nodeFactory,
            scene: scene,
            terrainNode: terrainNode,
            terrainOperations: terrainOperations,
            initialCameraNode: initialCameraNode,
            synthoidEnergy: synthoidEnergy,
            timeMachine: timeMachine,
            playerOperations: .init(
                terrainOperations: terrainOperations,
                synthoidEnergy: synthoidEnergy,
                initialCameraNode: initialCameraNode
            ),
            opponentsOperations: .init(
                opponentConfiguration: levelConfiguration,
                terrainOperations: terrainOperations,
                timeMachine: timeMachine
            )
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
            world: world,
            animatable: true
        )
    }
}
