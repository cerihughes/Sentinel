import SceneKit
@testable import Sentinel

class MockWorld: World {
    var terrainNode: TerrainNode?

    var scene = SCNScene()
    var initialCameraNode = SCNNode()

    func set(terrainNode: TerrainNode) {
        self.terrainNode = terrainNode
    }
}

extension WorldBuilder {
    static func createMock(
        levelConfiguration: MockLevelConfiguration = MockLevelConfiguration(),
        terrainGenerator: TerrainGenerator = DefaultTerrainGenerator(levelConfiguration: MockLevelConfiguration()),
        world: MockWorld = MockWorld()
    ) -> WorldBuilder {
        .init(
            levelConfiguration: levelConfiguration,
            terrainGenerator: terrainGenerator,
            materialFactory: MockMaterialFactory(),
            world: world
        )
    }
}
