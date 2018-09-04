import XCTest
@testable import Sentinel

class GridIndexTests: XCTestCase {

    func testNoBuilding() {
        let grid = Grid(width: 1, depth: 1)

        let index = GridIndex(grid: grid)
        XCTAssertEqual(index.flatLevels(), [0])
        XCTAssertEqual(index.pieces(at: 0).count, 1)
        XCTAssertEqual(index.lowestFlatPieces().count, 1)
        XCTAssertEqual(index.highestFlatPieces().count, 1)
    }

    func testInvalidLevel() {
        let grid = Grid(width: 1, depth: 1)

        let index = GridIndex(grid: grid)
        XCTAssertEqual(index.flatLevels(), [0])
        XCTAssertEqual(index.pieces(at: 1), [])
    }

    func test_1x1() {
        let grid = Grid(width: 1, depth: 1)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)

        let piece = grid.get(point: point)!
        let index = GridIndex(grid: grid)
        XCTAssertEqual(index.flatLevels(), [1])
        XCTAssertEqual(index.pieces(at: 1), [piece])
        XCTAssertEqual(index.lowestFlatPieces(), [piece])
        XCTAssertEqual(index.highestFlatPieces(), [piece])
    }

    func test_1x1_buildTwice() {
        let grid = Grid(width: 1, depth: 1)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)
        grid.build(at: point)

        let piece = grid.get(point: point)!
        let index = GridIndex(grid: grid)
        XCTAssertEqual(index.flatLevels(), [2])
        XCTAssertEqual(index.pieces(at: 2), [piece])
        XCTAssertEqual(index.lowestFlatPieces(), [piece])
        XCTAssertEqual(index.highestFlatPieces(), [piece])
    }

    func test_2x2() {
        let grid = Grid(width: 2, depth: 2)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)

        let index = GridIndex(grid: grid)
        XCTAssertEqual(index.flatLevels(), [0, 1])
        XCTAssertEqual(index.pieces(at: 0).count, 1)
        XCTAssertEqual(index.pieces(at: 1).count, 1)
        XCTAssertEqual(index.lowestFlatPieces().count, 1)
        XCTAssertEqual(index.highestFlatPieces().count, 1)
    }

    func test_2x2_buildTwice() {
        let grid = Grid(width: 2, depth: 2)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)
        grid.build(at: point)

        let index = GridIndex(grid: grid)
        XCTAssertEqual(index.flatLevels(), [2])
        XCTAssertEqual(index.pieces(at: 2).count, 1)
        XCTAssertEqual(index.lowestFlatPieces().count, 1)
        XCTAssertEqual(index.highestFlatPieces().count, 1)
    }

    func test_3x3() {
        let grid = Grid(width: 3, depth: 3)
        let point = GridPoint(x: 1, z: 1)
        grid.build(at: point)

        let index = GridIndex(grid: grid)
        XCTAssertEqual(index.flatLevels(), [0, 1])
        XCTAssertEqual(index.pieces(at: 0).count, 4)
        XCTAssertEqual(index.pieces(at: 1).count, 1)
        XCTAssertEqual(index.lowestFlatPieces().count, 4)
        XCTAssertEqual(index.highestFlatPieces().count, 1)
    }

    func test_3x3_buildTwice() {
        let grid = Grid(width: 3, depth: 3)
        let point = GridPoint(x: 1, z: 1)
        grid.build(at: point)
        grid.build(at: point)

        let index = GridIndex(grid: grid)
        XCTAssertEqual(index.flatLevels(), [2])
        XCTAssertEqual(index.pieces(at: 2).count, 1)
        XCTAssertEqual(index.lowestFlatPieces().count, 1)
        XCTAssertEqual(index.highestFlatPieces().count, 1)
    }
}
