import XCTest

@testable import Sentinel

class FloorIndexTests: XCTestCase {
    func testNoBuilding() {
        let grid = Grid(width: 1, depth: 1)

        let index = grid.emptyFloorPiecesByLevel()
        XCTAssertEqual(index.floorLevels(), [0])
        XCTAssertEqual(index.emptyFloorPieces(at: 0).count, 1)
        XCTAssertEqual(index.lowestEmptyFloorPieces().count, 1)
        XCTAssertEqual(index.highestEmptyFloorPieces().count, 1)
    }

    func testInvalidLevel() {
        let grid = Grid(width: 1, depth: 1)

        let index = grid.emptyFloorPiecesByLevel()
        XCTAssertEqual(index.floorLevels(), [0])
        XCTAssertEqual(index.emptyFloorPieces(at: 1), [])
    }

    func test_1x1() {
        let grid = Grid(width: 1, depth: 1)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)

        let piece = grid.get(point: point)!
        let index = grid.emptyFloorPiecesByLevel()
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
        let index = grid.emptyFloorPiecesByLevel()
        XCTAssertEqual(index.floorLevels(), [2])
        XCTAssertEqual(index.emptyFloorPieces(at: 2), [piece])
        XCTAssertEqual(index.lowestEmptyFloorPieces(), [piece])
        XCTAssertEqual(index.highestEmptyFloorPieces(), [piece])
    }

    func test_2x2() {
        let grid = Grid(width: 2, depth: 2)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)

        let index = grid.emptyFloorPiecesByLevel()
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

        let index = grid.emptyFloorPiecesByLevel()
        XCTAssertEqual(index.floorLevels(), [2])
        XCTAssertEqual(index.emptyFloorPieces(at: 2).count, 1)
        XCTAssertEqual(index.lowestEmptyFloorPieces().count, 1)
        XCTAssertEqual(index.highestEmptyFloorPieces().count, 1)
    }

    func test_3x3() {
        let grid = Grid(width: 3, depth: 3)
        let point = GridPoint(x: 1, z: 1)
        grid.build(at: point)

        let index = grid.emptyFloorPiecesByLevel()
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

        let index = grid.emptyFloorPiecesByLevel()
        XCTAssertEqual(index.floorLevels(), [2])
        XCTAssertEqual(index.emptyFloorPieces(at: 2).count, 1)
        XCTAssertEqual(index.lowestEmptyFloorPieces().count, 1)
        XCTAssertEqual(index.highestEmptyFloorPieces().count, 1)
    }

    func testLargeGrid() {
        let grid = Grid(width: 7, depth: 5)
        grid.build(at: GridPoint(x: 3, z: 3))
        grid.build(at: GridPoint(x: 3, z: 3))
        grid.build(at: GridPoint(x: 3, z: 0))
        grid.processSlopes()

        let index = grid.emptyFloorPiecesByLevel()
        XCTAssertEqual(index.floorLevels(), [0, 1, 2])
        XCTAssertEqual(index[0]?.count, 20)
        XCTAssertEqual(index[1]?.count, 1)
        XCTAssertEqual(index[2]?.count, 1)
        XCTAssertNil(index[3])

//        assertPiece(in: grid, z: 0, description: "****:0.0 ****:0.0 ****:0.0 N***:0.5 ****:0.0 ****:0.0 ****:0.0")
//        assertPiece(in: grid, z: 1, description: "****:0.0 ****:0.0 N**W:0.5 N***:1.5 NE**:0.5 ****:0.0 ****:0.0")
//        assertPiece(in: grid, z: 2, description: "****:0.0 N**W:0.5 N**W:1.5 N***:2.5 NE**:1.5 NE**:0.5 ****:0.0")
//        assertPiece(in: grid, z: 3, description: "***W:0.5 ***W:1.5 ***W:2.5 ****:3.0 *E**:2.5 *E**:1.5 *E**:0.5")
//        assertPiece(in: grid, z: 4, description: "****:0.0 **SW:0.5 **SW:1.5 **S*:2.5 *ES*:1.5 *ES*:0.5 ****:0.0")
    }
}

extension GridPiece: Equatable {
    public static func == (lhs: GridPiece, rhs: GridPiece) -> Bool {
        lhs.point == rhs.point && lhs.isFloor == rhs.isFloor && lhs.level == rhs.level && lhs.slopes == rhs.slopes
    }
}
