import XCTest
@testable import Sentinel

class GridTests: XCTestCase {

    func test_1x1() {
        let grid = Grid(width: 1, depth: 1)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)

        assertPiece(in: grid, x: 0, z: 0, description: "0:1")
    }

    func test_1x1_buildTwice() {
        let grid = Grid(width: 1, depth: 1)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)
        grid.build(at: point)

        assertPiece(in: grid, x: 0, z: 0, description: "0:2")
    }

    func test_2x2() {
        let grid = Grid(width: 2, depth: 2)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)

        assertPiece(in: grid, z: 0, description: "0:1 2:0")
        assertPiece(in: grid, z: 1, description: "4:0 0:0")
    }

    func test_2x2_buildTwice() {
        let grid = Grid(width: 2, depth: 2)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)
        grid.build(at: point)

        assertPiece(in: grid, z: 0, description: "0:2 2:1")
        assertPiece(in: grid, z: 1, description: "4:1 6:0")
    }

    func test_2x2_adjacentHorizontalBuilds() {
        let grid = Grid(width: 2, depth: 2)
        let point1 = GridPoint(x: 0, z: 0)
        let point2 = GridPoint(x: 1, z: 0)
        grid.build(at: point1)
        grid.build(at: point2)

        assertPiece(in: grid, z: 0, description: "0:1 0:1")
        assertPiece(in: grid, z: 1, description: "4:0 4:0")
    }

    func test_3x3() {
        let grid = Grid(width: 3, depth: 3)
        let point = GridPoint(x: 1, z: 1)
        grid.build(at: point)

        assertPiece(in: grid, z: 0, description: "0:0 1:0 0:0")
        assertPiece(in: grid, z: 1, description: "8:0 0:1 2:0")
        assertPiece(in: grid, z: 2, description: "0:0 4:0 0:0")
    }

    func test_3x3_buildTwice() {
        let grid = Grid(width: 3, depth: 3)
        let point = GridPoint(x: 1, z: 1)
        grid.build(at: point)
        grid.build(at: point)

        assertPiece(in: grid, z: 0, description: "9:0 1:1 3:0")
        assertPiece(in: grid, z: 1, description: "8:1 0:2 2:1")
        assertPiece(in: grid, z: 2, description: "c:0 4:1 6:0")
    }

    func test_3x1_withSpacer() {
        let grid = Grid(width: 3, depth: 1)
        let point1 = GridPoint(x: 0, z: 0)
        let point2 = GridPoint(x: 2, z: 0)
        grid.build(at: point1)
        grid.build(at: point2)

        assertPiece(in: grid, z: 0, description: "0:1 a:0 0:1")
    }

    func test_3x3_withSpacer() {
        let grid = Grid(width: 3, depth: 3)
        let point1 = GridPoint(x: 1, z: 0)
        let point2 = GridPoint(x: 0, z: 1)
        let point3 = GridPoint(x: 2, z: 1)
        let point4 = GridPoint(x: 1, z: 2)
        grid.build(at: point1)
        grid.build(at: point2)
        grid.build(at: point3)
        grid.build(at: point4)

        assertPiece(in: grid, z: 0, description: "9:0 0:1 3:0")
        assertPiece(in: grid, z: 1, description: "0:1 f:0 0:1")
        assertPiece(in: grid, z: 2, description: "c:0 0:1 6:0")
    }

    func testLargeGrid() {
        let grid = Grid(width: 7, depth: 7)
        grid.build(at: GridPoint(x: 3, z: 3))
        print(grid)
        grid.build(at: GridPoint(x: 3, z: 3))
        print(grid)
        grid.build(at: GridPoint(x: 3, z: 3))
        print(grid)

        assertPiece(in: grid, z: 0, description: "0:0 0:0 0:0 1:0 0:0 0:0 0:0")
        assertPiece(in: grid, z: 1, description: "0:0 0:0 9:0 1:1 3:0 0:0 0:0")
        assertPiece(in: grid, z: 2, description: "0:0 9:0 9:1 1:2 3:1 3:0 0:0")
        assertPiece(in: grid, z: 3, description: "8:0 8:1 8:2 0:3 2:2 2:1 2:0")
        assertPiece(in: grid, z: 4, description: "0:0 c:0 c:1 4:2 6:1 6:0 0:0")
        assertPiece(in: grid, z: 5, description: "0:0 0:0 c:0 4:1 6:0 0:0 0:0")
        assertPiece(in: grid, z: 6, description: "0:0 0:0 0:0 4:0 0:0 0:0 0:0")
    }

    private func assertPiece(in grid: Grid,
                             z: Int,
                             description: String,
                             file: StaticString = #file,
                             line: UInt = #line) {
        let width = grid.width
        let descriptions = description.components(separatedBy: " ")
        XCTAssertEqual(width, descriptions.count, file: file, line: line)
        for (index, value) in descriptions.enumerated() {
            assertPiece(in: grid, x: index, z: z, description: value, file: file, line: line)
        }
    }

    private func assertPiece(in grid: Grid,
                             x: Int,
                             z: Int,
                             description: String,
                             file: StaticString = #file,
                             line: UInt = #line) {
        let point = GridPoint(x: x, z: z)
        let piece = grid.get(point: point)
        let actualDescription = piece.description
        XCTAssertEqual(actualDescription, description, file: file, line: line)
    }
}
