import XCTest

@testable import Sentinel

class FloorIndexTests: XCTestCase {
    func testNoBuilding() {
        let grid = Grid(width: 1, depth: 1)

        let index = grid.createFloorIndex()
        XCTAssertEqual(index.floorLevels(), [0])
        XCTAssertEqual(index.emptyFloorPieces(at: 0).count, 1)
        XCTAssertEqual(index.lowestEmptyFloorPieces().count, 1)
        XCTAssertEqual(index.highestEmptyFloorPieces().count, 1)
    }

    func testInvalidLevel() {
        let grid = Grid(width: 1, depth: 1)

        let index = grid.createFloorIndex()
        XCTAssertEqual(index.floorLevels(), [0])
        XCTAssertEqual(index.emptyFloorPieces(at: 1), [])
    }

    func test_1x1() {
        let grid = Grid(width: 1, depth: 1)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)

        let piece = grid.get(point: point)!
        let index = grid.createFloorIndex()
        XCTAssertEqual(index.floorLevels(), [1])
        XCTAssertEqual(index.emptyFloorPieces(at: 1), [piece])
        XCTAssertEqual(index.lowestEmptyFloorPieces(), [piece])
        XCTAssertEqual(index.highestEmptyFloorPieces(), [piece])
    }

    func test_1x1_buildTwice() {
        let grid = Grid(width: 1, depth: 1)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)
        grid.build(at: point)

        let piece = grid.get(point: point)!
        let index = grid.createFloorIndex()
        XCTAssertEqual(index.floorLevels(), [2])
        XCTAssertEqual(index.emptyFloorPieces(at: 2), [piece])
        XCTAssertEqual(index.lowestEmptyFloorPieces(), [piece])
        XCTAssertEqual(index.highestEmptyFloorPieces(), [piece])
    }

    func test_2x2() {
        let grid = Grid(width: 2, depth: 2)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)

        let index = grid.createFloorIndex()
        XCTAssertEqual(index.floorLevels(), [0, 1])
        XCTAssertEqual(index.emptyFloorPieces(at: 0).count, 1)
        XCTAssertEqual(index.emptyFloorPieces(at: 1).count, 1)
        XCTAssertEqual(index.lowestEmptyFloorPieces().count, 1)
        XCTAssertEqual(index.highestEmptyFloorPieces().count, 1)
    }

    func test_2x2_buildTwice() {
        let grid = Grid(width: 2, depth: 2)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)
        grid.build(at: point)

        let index = grid.createFloorIndex()
        XCTAssertEqual(index.floorLevels(), [2])
        XCTAssertEqual(index.emptyFloorPieces(at: 2).count, 1)
        XCTAssertEqual(index.lowestEmptyFloorPieces().count, 1)
        XCTAssertEqual(index.highestEmptyFloorPieces().count, 1)
    }

    func test_3x3() {
        let grid = Grid(width: 3, depth: 3)
        let point = GridPoint(x: 1, z: 1)
        grid.build(at: point)

        let index = grid.createFloorIndex()
        XCTAssertEqual(index.floorLevels(), [0, 1])
        XCTAssertEqual(index.emptyFloorPieces(at: 0).count, 4)
        XCTAssertEqual(index.emptyFloorPieces(at: 1).count, 1)
        XCTAssertEqual(index.lowestEmptyFloorPieces().count, 4)
        XCTAssertEqual(index.highestEmptyFloorPieces().count, 1)
    }

    func test_3x3_buildTwice() {
        let grid = Grid(width: 3, depth: 3)
        let point = GridPoint(x: 1, z: 1)
        grid.build(at: point)
        grid.build(at: point)

        let index = grid.createFloorIndex()
        XCTAssertEqual(index.floorLevels(), [2])
        XCTAssertEqual(index.emptyFloorPieces(at: 2).count, 1)
        XCTAssertEqual(index.lowestEmptyFloorPieces().count, 1)
        XCTAssertEqual(index.highestEmptyFloorPieces().count, 1)
    }
}

extension GridPiece: Equatable {
    public static func == (lhs: GridPiece, rhs: GridPiece) -> Bool {
        lhs.point == rhs.point && lhs.isFloor == rhs.isFloor && lhs.level == rhs.level && lhs.slopes == rhs.slopes
    }
}
