import SceneKit

class GameSummaryViewModel {
    private let level: Int
    private let localDataSource: LocalDataSource
    let terrain: WorldBuilder.Terrain
    private let operations: WorldBuilder.Operations

    private var terrainOperations: TerrainOperations {
        terrain.terrainOperations
    }

    init?(level: Int, worldBuilder: WorldBuilder, localDataSource: LocalDataSource) {
        guard
            let text = localDataSource.completionText(for: level),
            let image = UIImage.create(text: text, font: .systemFont(ofSize: 12))
        else {
            return nil
        }
        self.level = level
        self.localDataSource = localDataSource
        let worldBuilder = WorldBuilder(
            terrainGenerator: ImageTerrainGenerator(image: image),
            materialFactory: IntroMaterialFactory(),
            world: EmptyWorld(),
            animatable: true
        )
        terrain = worldBuilder.buildTerrain(initialCameraPosition: .init(0, 1000, 10))
        operations = terrain.createOperations()
    }

    func animateCamera() {
        plantTree()
    }

    func nextNavigationToken() -> Navigation? {
        guard let levelScores = localDataSource.levelScores(for: level), levelScores.outcome == .victory else {
            return nil
        }
        return .gamePreview(level: level + levelScores.nextLevelIncrement)
    }

    private func plantTree() {
        guard
            let point = terrainOperations.grid.randomTreePosition,
            let floorNode = terrain.nodeMap.floorNode(at: point)
        else {
            return
        }

        terrain.initialCameraNode.position = floorNode.worldPosition.adding(z: 50)
        terrain.initialCameraNode.look(at: floorNode.worldPosition)

        terrainOperations.buildRock(at: point, animated: true) { [weak self] in
            self?.terrainOperations.buildTree(at: point, animated: true) { [weak self] in
                self?.animateUp(from: floorNode)
            }
        }
    }

    private func animateUp(from floorNode: FloorNode) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1
        terrain.initialCameraNode.position = floorNode.worldPosition.adding(y: 50, z: 50)
        self.terrain.initialCameraNode.look(at: self.terrain.terrainNode.worldPosition)
        SCNTransaction.completionBlock = { [weak self] in
            self?.animateAway()
        }
        SCNTransaction.commit()
    }

    private func animateAway() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 5
        self.terrain.initialCameraNode.position = .init(0, 3000, 1000)
        self.terrain.initialCameraNode.look(at: self.terrain.terrainNode.worldPosition)
        SCNTransaction.commit()
    }
}

private extension LocalDataSource {
    func completionText(for level: Int) -> String? {
        levelScores(for: level)?.completionText(for: level)
    }

    func levelScores(for level: Int) -> LevelScore? {
        localStorage.gameScore?.levelScores[level]
    }
}

private extension LevelScore {
    func completionText(for level: Int) -> String? {
        guard outcome == .victory else { return nil }
        return """
Level \(level) Summary

Trees Built: \(treesBuilt)
Rocks Built: \(rocksBuilt)
Synthoids Built: \(synthoidsBuilt)
Teleports: \(teleports)
Final Energy: \(finalEnergy)
Next Level: \(level + nextLevelIncrement)
"""
    }

    var nextLevelIncrement: Int {
        max(finalEnergy / 4, 1)
    }
}

private extension Grid {
    var randomTreePosition: GridPoint? {
        emptyFloorPieces()
            .filter { $0.level == 1.0 }
            .randomElement()?
            .point
    }
}
