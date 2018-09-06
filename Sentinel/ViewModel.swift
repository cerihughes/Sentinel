import Foundation

class ViewModel: NSObject {
    let tg = TerrainGenerator()

    var grid: Grid!
    var nodeFactory: NodeFactory!

    private (set) var nextTerrainIndex = 0

    override init() {
        super.init()

        nextLevel()
    }

    func nextLevel() {
        grid = tg.generate(level: nextTerrainIndex,
                               maxLevel: 99,
                               minWidth: 24,
                               maxWidth: 32,
                               minDepth: 16,
                               maxDepth: 24)

        nodeFactory = NodeFactory(grid: grid, sideLength: 10.0)

        nextTerrainIndex += 1
    }
}
