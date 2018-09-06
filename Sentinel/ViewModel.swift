import Foundation

class ViewModel: NSObject {
    let terrainIndex: Int
    let grid: Grid
    let nodeFactory: NodeFactory

    init(terrainIndex: Int) {
        self.terrainIndex = terrainIndex

        let tg = TerrainGenerator()
        self.grid = tg.generate(level: terrainIndex,
                                maxLevel: 99,
                                minWidth: 24,
                                maxWidth: 32,
                                minDepth: 16,
                                maxDepth: 24)

        let nodePositioning = NodePositioning(gridWidth: Float(grid.width),
                                              gridDepth: Float(grid.depth),
                                              sideLength: 10.0)

        self.nodeFactory = NodeFactory(nodePositioning: nodePositioning)

        super.init()
    }
}
