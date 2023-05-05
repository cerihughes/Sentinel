import XCTest
@testable import Sentinel

final class TerrainGeneratorTests: XCTestCase {

    private var tg: TerrainGenerator!

    override func setUp() {
        super.setUp()
        tg = DefaultTerrainGenerator()
    }

    override func tearDown() {
        tg = nil
        super.tearDown()
    }

    func testLevel0() throws {
        let config = DefaultLevelConfiguration(level: 0)
        let grid = tg.generate(levelConfiguration: config)
        let piece = try XCTUnwrap(grid.get(point: grid.sentinelPosition))
        XCTAssertEqual(piece.level, 7)
        XCTAssertEqual(grid.contentsDescription, .expectedGrid0)
    }

    func testLevel10() throws {
        let config = DefaultLevelConfiguration(level: 10)
        let grid = tg.generate(levelConfiguration: config)

        let piece = try XCTUnwrap(grid.get(point: grid.sentinelPosition))
        XCTAssertEqual(piece.level, 8)
        XCTAssertEqual(grid.contentsDescription, .expectedGrid10)
    }

    func testLevel20() throws {
        let config = DefaultLevelConfiguration(level: 20)
        let grid = tg.generate(levelConfiguration: config)

        let piece = try XCTUnwrap(grid.get(point: grid.sentinelPosition))
        XCTAssertEqual(piece.level, 9)
        XCTAssertEqual(grid.contentsDescription, .expectedGrid20)
    }

    func testLevel30() throws {
        let config = DefaultLevelConfiguration(level: 30)
        let grid = tg.generate(levelConfiguration: config)

        let piece = try XCTUnwrap(grid.get(point: grid.sentinelPosition))
        XCTAssertEqual(piece.level, 11)
        XCTAssertEqual(grid.contentsDescription, .expectedGrid30)
    }

    func testLevel40() throws {
        let config = DefaultLevelConfiguration(level: 40)
        let grid = tg.generate(levelConfiguration: config)

        XCTAssertEqual(grid.width, 35)
        XCTAssertEqual(grid.depth, 27)

        let piece = try XCTUnwrap(grid.get(point: grid.sentinelPosition))
        XCTAssertEqual(piece.level, 8)

        XCTAssertEqual(grid.contentsDescription, .expectedGrid40)
    }
}
