import XCTest
@testable import Sentinel

final class TerrainGeneratorTests: XCTestCase {

    func testLevel0() throws {
        let tg = DefaultTerrainGenerator(level: 0)
        let grid = tg.generate()
        let piece = try XCTUnwrap(grid.piece(at: grid.sentinelPosition))
        XCTAssertEqual(piece.level, 7)
        XCTAssertEqual(grid.contentsDescription, .expectedGrid0)
    }

    func testLevel10() throws {
        let tg = DefaultTerrainGenerator(level: 10)
        let grid = tg.generate()

        let piece = try XCTUnwrap(grid.piece(at: grid.sentinelPosition))
        XCTAssertEqual(piece.level, 8)
        XCTAssertEqual(grid.contentsDescription, .expectedGrid10)
    }

    func testLevel20() throws {
        let tg = DefaultTerrainGenerator(level: 20)
        let grid = tg.generate()

        let piece = try XCTUnwrap(grid.piece(at: grid.sentinelPosition))
        XCTAssertEqual(piece.level, 9)
        XCTAssertEqual(grid.contentsDescription, .expectedGrid20)
    }

    func testLevel30() throws {
        let tg = DefaultTerrainGenerator(level: 30)
        let grid = tg.generate()

        let piece = try XCTUnwrap(grid.piece(at: grid.sentinelPosition))
        XCTAssertEqual(piece.level, 11)
        XCTAssertEqual(grid.contentsDescription, .expectedGrid30)
    }

    func testLevel40() throws {
        let tg = DefaultTerrainGenerator(level: 40)
        let grid = tg.generate()

        XCTAssertEqual(grid.width, 35)
        XCTAssertEqual(grid.depth, 27)

        let piece = try XCTUnwrap(grid.piece(at: grid.sentinelPosition))
        XCTAssertEqual(piece.level, 8)
        XCTAssertEqual(grid.contentsDescription, .expectedGrid40)
    }
}

private extension DefaultTerrainGenerator {
    convenience init(level: Int) {
        self.init(levelConfiguration: DefaultLevelConfiguration(level: level))
    }
}
