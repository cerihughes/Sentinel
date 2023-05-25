import SceneKit

struct WorldBuilder {
    struct Terrain {
        let nodeMap: NodeMap
        let nodeManipulator: NodeManipulator
        let nodeFactory: NodeFactory
        let scene: SCNScene
        let terrainNode: TerrainNode
        let terrainOperations: TerrainOperations
        let initialCameraNode: SCNNode
    }
    struct Operations {
        let synthoidEnergy: SynthoidEnergy
        let timeMachine: TimeMachine
        let playerOperations: PlayerOperations
        let opponentsOperations: OpponentsOperations
    }
    let terrainGenerator: TerrainGenerator
    let materialFactory: MaterialFactory
    let world: World
    let animatable: Bool

    func buildTerrain(initialCameraPosition: SCNVector3 = .initialCameraPosition) -> Terrain {
        let grid = terrainGenerator.generate()
        let nodeMap = NodeMap()
        let nodePositioning = grid.createNodePositioning()
        let nodeFactory = NodeFactory(nodePositioning: nodePositioning, materialFactory: materialFactory)
        let terrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: nodeMap)
        let scene = SCNScene()
        world.buildWorld(in: scene, around: terrainNode)

        let initialCameraNode = nodeFactory.createSynthoidNode(height: 0, viewingAngle: 0.0).cameraNode
        initialCameraNode.position = initialCameraPosition
        initialCameraNode.look(at: terrainNode.position)

        terrainNode.addChildNode(initialCameraNode)

        let nodeManipulator = NodeManipulator(
            terrainNode: terrainNode,
            nodeFactory: nodeFactory,
            animatable: animatable
        )
        let terrainOperations = TerrainOperations(grid: grid, nodeMap: nodeMap, nodeManipulator: nodeManipulator)
        return .init(
            nodeMap: nodeMap,
            nodeManipulator: nodeManipulator,
            nodeFactory: nodeFactory,
            scene: scene,
            terrainNode: terrainNode,
            terrainOperations: terrainOperations,
            initialCameraNode: initialCameraNode
        )
    }
}

extension WorldBuilder.Terrain {
    private var grid: Grid {
        terrainOperations.grid
    }

    func createOperations() -> WorldBuilder.Operations {
        let synthoidEnergy = SynthoidEnergyMonitor()
        let timeMachine = TimeMachine()
        return .init(
            synthoidEnergy: synthoidEnergy,
            timeMachine: timeMachine,
            playerOperations: .init(
                terrainOperations: terrainOperations,
                synthoidEnergy: synthoidEnergy,
                initialCameraNode: initialCameraNode
            ),
            opponentsOperations: .init(terrainOperations: terrainOperations, timeMachine: timeMachine)
        )
    }
}

extension WorldBuilder {
    static func createDefault(level: Int, world: World = SpaceWorld()) -> WorldBuilder {
        let levelConfiguration = DefaultLevelConfiguration(level: level)
        return .init(
            terrainGenerator: DefaultTerrainGenerator(levelConfiguration: levelConfiguration),
            materialFactory: DefaultMaterialFactory(level: level),
            world: world,
            animatable: true
        )
    }
}

extension SCNVector3 {
    static let initialCameraPosition = SCNVector3(0, 250, 275)
}
