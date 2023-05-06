import XCTest
@testable import Sentinel

final class GridTests: XCTestCase {

    func test_3x3_noBuild() {
        let builder = GridBuilder(width: 3, depth: 3)
        builder.processSlopes()
        let grid = builder.buildGrid()

        XCTAssertEqual(grid.emptyFloorPieces().count, 9)
    }

    func test_3x3_buildTwice() throws {
        let builder = GridBuilder(width: 3, depth: 3)
        let point = GridPoint(x: 1, z: 1)
        builder.buildFloor(at: point)
        builder.buildFloor(at: point)
        builder.processSlopes()
        let grid = builder.buildGrid()

        XCTAssertEqual(grid.emptyFloorPieces().count, 1)
        let slopePiece = try XCTUnwrap(grid.piece(at: .init(x: 0, z: 0)))
        let floorPiece = try XCTUnwrap(grid.piece(at: .init(x: 1, z: 1)))
        XCTAssertFalse(slopePiece.isFloor)
        XCTAssertTrue(floorPiece.isFloor)
    }
}
