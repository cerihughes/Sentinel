import Foundation
@testable import Sentinel

final class MockTerrainGenerator: TerrainGenerator {
    let grid: Grid

    init(grid: Grid) {
        self.grid = grid
    }

    convenience init() {
        let grid = GridBuilder(width: 4, depth: 4).buildGrid()
        self.init(grid: grid)
    }

    func generate() -> Grid {
        grid
    }
}
