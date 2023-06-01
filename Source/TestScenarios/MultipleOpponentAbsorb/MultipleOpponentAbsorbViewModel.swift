#if DEBUG
import SceneKit

/// A test scenario to make sure multiple opponents don't try and absorb the same objects at the same time.
class MultipleOpponentAbsorbViewModel {
    private let terrain: WorldBuilder.Terrain
    private let operations: WorldBuilder.Operations
    private let initialTrees: Int
    private let rocksCreated: Int
    private var absorbed = 0

    var scene: SCNScene { terrain.scene }
    var cameraNode: SCNNode { terrain.initialCameraNode }
    var timeMachine: TimeMachine { operations.timeMachine }

    init() {
        let builder = WorldBuilder.createDefault(level: 45)
        terrain = builder.buildTerrain(initialCameraPosition: .init(50, 300, 300))
        operations = terrain.createOperations()
        initialTrees = terrain.terrainOperations.grid.treePositions.count
        rocksCreated = terrain.terrainOperations.addRockNodesToLowestLevel()

        operations.opponentsOperations.delegate = self
        operations.playerOperations.enterScene()
        operations.timeMachine.start()
    }
}

extension MultipleOpponentAbsorbViewModel: OpponentsOperationsDelegate {
    private var grid: Grid { terrain.terrainOperations.grid }

    func opponentsOperationsDidAbsorb(_: OpponentsOperations) {
        absorbed += 1

        if absorbed == expectedAbsorptions {
            assert(grid.allRockPositions().isEmpty)
            assert(grid.treePositions.count == expectedTrees)
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

private extension TerrainOperations {
    func addRockNodesToLowestLevel() -> Int {
        let points = grid.emptyFloorPieces()
            .filter { Int($0.level) > 1 }
            .map { $0.point }
        points.forEach { buildRock(at: $0) }
        return points.count
    }
}
#endif
