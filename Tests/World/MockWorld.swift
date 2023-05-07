import SceneKit
@testable import Sentinel

class MockWorld: World {
    var terrainNode: TerrainNode?

    var scene = SCNScene()
    var initialCameraNode = SCNNode()

    func set(terrainNode: TerrainNode) {
        self.terrainNode = terrainNode
        scene.rootNode.addChildNode(terrainNode)
    }
}

extension WorldBuilder {
    static func createMock(
        levelConfiguration: MockLevelConfiguration = MockLevelConfiguration(),
        terrainGenerator: TerrainGenerator = DefaultTerrainGenerator(gridConfiguration: MockLevelConfiguration()),
        world: MockWorld = MockWorld()
    ) -> WorldBuilder {
        .init(
            levelConfiguration: levelConfiguration,
            terrainGenerator: terrainGenerator,
            materialFactory: MockMaterialFactory(),
            world: world
        )
    }

    static func createMock(
        levelConfiguration: MockLevelConfiguration = MockLevelConfiguration(),
        grid: Grid,
        world: MockWorld = MockWorld()
    ) -> WorldBuilder {
        let terrainGenerator = MockTerrainGenerator(grid: grid)
        return .init(
            levelConfiguration: levelConfiguration,
            terrainGenerator: terrainGenerator,
            materialFactory: MockMaterialFactory(),
            world: world
        )
    }
}
