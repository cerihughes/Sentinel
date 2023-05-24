import SceneKit
@testable import Sentinel

class MockWorld: World {
    var scene: SCNScene?
    var terrainNode: TerrainNode?

    func buildWorld(in scene: SCNScene, around terrainNode: TerrainNode) {
        self.scene = scene
        self.terrainNode = terrainNode
        scene.rootNode.addChildNode(terrainNode)
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
            world: world,
            animatable: false
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
            world: world,
            animatable: false
        )
    }
}
