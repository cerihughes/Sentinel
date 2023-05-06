import XCTest

@testable import Sentinel

class GridBuilderFloorTests: XCTestCase {
    func testNoBuilding() {
        let builder = GridBuilder(width: 1, depth: 1)

        let index = builder.emptyFloorPiecesByLevel()
        XCTAssertEqual(index.floorLevels(), [0])
        XCTAssertEqual(index.emptyFloorPieces(at: 0).count, 1)
        XCTAssertEqual(index.lowestEmptyFloorPieces().count, 1)
        XCTAssertEqual(index.highestEmptyFloorPieces().count, 1)
    }

    func testInvalidLevel() {
        let builder = GridBuilder(width: 1, depth: 1)

        let index = builder.emptyFloorPiecesByLevel()
        XCTAssertEqual(index.floorLevels(), [0])
        XCTAssertEqual(index.emptyFloorPieces(at: 1), [])
    }

    func test_1x1() throws {
        let builder = GridBuilder(width: 1, depth: 1)
        let point = GridPoint(x: 0, z: 0)
        builder.buildFloor(at: point)

        let piece = try XCTUnwrap(builder.piece(at: point))
        let index = builder.emptyFloorPiecesByLevel()
        XCTAssertEqual(index.floorLevels(), [1])
        XCTAssertEqual(index.emptyFloorPieces(at: 1), [piece])
        XCTAssertEqual(index.lowestEmptyFloorPieces(), [piece])
        XCTAssertEqual(index.highestEmptyFloorPieces(), [piece])
    }

    func test_1x1_buildTwice() throws {
        let builder = GridBuilder(width: 1, depth: 1)
        let point = GridPoint(x: 0, z: 0)
        builder.buildFloor(at: point)
        builder.buildFloor(at: point)

        let piece = try XCTUnwrap(builder.piece(at: point))
        let index = builder.emptyFloorPiecesByLevel()
        XCTAssertEqual(index.floorLevels(), [2])
        XCTAssertEqual(index.emptyFloorPieces(at: 2), [piece])
        XCTAssertEqual(index.lowestEmptyFloorPieces(), [piece])
        XCTAssertEqual(index.highestEmptyFloorPieces(), [piece])
    }

    func test_2x2() {
        let builder = GridBuilder(width: 2, depth: 2)
        let point = GridPoint(x: 0, z: 0)
        builder.buildFloor(at: point)

        let index = builder.emptyFloorPiecesByLevel()
        XCTAssertEqual(index.floorLevels(), [0, 1])
        XCTAssertEqual(index.emptyFloorPieces(at: 0).count, 1)
        XCTAssertEqual(index.emptyFloorPieces(at: 1).count, 1)
        XCTAssertEqual(index.lowestEmptyFloorPieces().count, 1)
        XCTAssertEqual(index.highestEmptyFloorPieces().count, 1)
    }

    func test_2x2_buildTwice() {
        let builder = GridBuilder(width: 2, depth: 2)
        let point = GridPoint(x: 0, z: 0)
        builder.buildFloor(at: point)
        builder.buildFloor(at: point)

        let index = builder.emptyFloorPiecesByLevel()
        XCTAssertEqual(index.floorLevels(), [2])
        XCTAssertEqual(index.emptyFloorPieces(at: 2).count, 1)
        XCTAssertEqual(index.lowestEmptyFloorPieces().count, 1)
        XCTAssertEqual(index.highestEmptyFloorPieces().count, 1)
    }

    func test_3x3() {
        let builder = GridBuilder(width: 3, depth: 3)
        let point = GridPoint(x: 1, z: 1)
        builder.buildFloor(at: point)

        let index = builder.emptyFloorPiecesByLevel()
        XCTAssertEqual(index.floorLevels(), [0, 1])
        XCTAssertEqual(index.emptyFloorPieces(at: 0).count, 4)
        XCTAssertEqual(index.emptyFloorPieces(at: 1).count, 1)
        XCTAssertEqual(index.lowestEmptyFloorPieces().count, 4)
        XCTAssertEqual(index.highestEmptyFloorPieces().count, 1)
    }

    func test_3x3_buildTwice() {
        let builder = GridBuilder(width: 3, depth: 3)
        let point = GridPoint(x: 1, z: 1)
        builder.buildFloor(at: point)
        builder.buildFloor(at: point)

        let index = builder.emptyFloorPiecesByLevel()
        XCTAssertEqual(index.floorLevels(), [2])
        XCTAssertEqual(index.emptyFloorPieces(at: 2).count, 1)
        XCTAssertEqual(index.lowestEmptyFloorPieces().count, 1)
        XCTAssertEqual(index.highestEmptyFloorPieces().count, 1)
    }

    func testLargeGrid() {
        let builder = GridBuilder(width: 7, depth: 5)
        builder.buildFloor(at: GridPoint(x: 3, z: 3))
        builder.buildFloor(at: GridPoint(x: 3, z: 3))
        builder.buildFloor(at: GridPoint(x: 3, z: 0))

        let index = builder.emptyFloorPiecesByLevel()
        XCTAssertEqual(index.floorLevels(), [0, 1, 2])
        XCTAssertEqual(index[0]?.count, 20)
        XCTAssertEqual(index[1]?.count, 1)
        XCTAssertEqual(index[2]?.count, 1)
        XCTAssertNil(index[3])
    }
}

extension GridPiece: Equatable {
    public static func == (lhs: GridPiece, rhs: GridPiece) -> Bool {
        lhs.point == rhs.point && lhs.isFloor == rhs.isFloor && lhs.level == rhs.level && lhs.slopes == rhs.slopes
    }
}
