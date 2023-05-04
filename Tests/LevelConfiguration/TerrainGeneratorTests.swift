import XCTest
@testable import Sentinel

final class TerrainGeneratorTests: XCTestCase {

    private var tg: TerrainGenerator!

    override func setUp() {
        super.setUp()
        tg = TerrainGenerator()
    }

    override func tearDown() {
        tg = nil
        super.tearDown()
    }

    func testLevel0() throws {
        let config = DefaultLevelConfiguration(level: 0)
        let grid = tg.generate(levelConfiguration: config)

        XCTAssertEqual(grid.width, 32)
        XCTAssertEqual(grid.depth, 24)

        XCTAssertEqual(grid.treePositions.count, 17)
        XCTAssertEqual(grid.sentryPositions.count, 0)
        XCTAssertEqual(grid.rockPositions.count, 0)

        let expectedSentinelPosition = GridPoint(x: 31, z: 17)
        XCTAssertEqual(grid.sentinelPosition, expectedSentinelPosition)

        let piece = try XCTUnwrap(grid.get(point: expectedSentinelPosition))
        XCTAssertEqual(piece.level, 7)
    }

    func testLevel10() throws {
        let config = DefaultLevelConfiguration(level: 10)
        let grid = tg.generate(levelConfiguration: config)

        XCTAssertEqual(grid.width, 32)
        XCTAssertEqual(grid.depth, 24)

        XCTAssertEqual(grid.treePositions.count, 16)
        XCTAssertEqual(grid.sentryPositions.count, 1)
        XCTAssertEqual(grid.rockPositions.count, 0)

        let expectedSentinelPosition = GridPoint(x: 30, z: 23)
        XCTAssertEqual(grid.sentinelPosition, expectedSentinelPosition)

        let piece = try XCTUnwrap(grid.get(point: expectedSentinelPosition))
        XCTAssertEqual(piece.level, 8)
    }

    func testLevel20() throws {
        let config = DefaultLevelConfiguration(level: 20)
        let grid = tg.generate(levelConfiguration: config)

        XCTAssertEqual(grid.width, 33)
        XCTAssertEqual(grid.depth, 25)

        XCTAssertEqual(grid.treePositions.count, 15)
        XCTAssertEqual(grid.sentryPositions.count, 2)
        XCTAssertEqual(grid.rockPositions.count, 0)

        let expectedSentinelPosition = GridPoint(x: 24, z: 24)
        XCTAssertEqual(grid.sentinelPosition, expectedSentinelPosition)

        let piece = try XCTUnwrap(grid.get(point: expectedSentinelPosition))
        XCTAssertEqual(piece.level, 9)
    }

    func testLevel30() throws {
        let config = DefaultLevelConfiguration(level: 30)
        let grid = tg.generate(levelConfiguration: config)

        XCTAssertEqual(grid.width, 34)
        XCTAssertEqual(grid.depth, 26)

        XCTAssertEqual(grid.treePositions.count, 12)
        XCTAssertEqual(grid.sentryPositions.count, 3)
        XCTAssertEqual(grid.rockPositions.count, 0)

        let expectedSentinelPosition = GridPoint(x: 17, z: 12)
        XCTAssertEqual(grid.sentinelPosition, expectedSentinelPosition)

        let piece = try XCTUnwrap(grid.get(point: expectedSentinelPosition))
        XCTAssertEqual(piece.level, 11)
    }

    func testLevel40() throws {
        let config = DefaultLevelConfiguration(level: 40)
        let grid = tg.generate(levelConfiguration: config)

        XCTAssertEqual(grid.width, 35)
        XCTAssertEqual(grid.depth, 27)

        XCTAssertEqual(grid.treePositions.count, 13)
        XCTAssertEqual(grid.sentryPositions.count, 3)
        XCTAssertEqual(grid.rockPositions.count, 0)

        let expectedSentinelPosition = GridPoint(x: 15, z: 11)
        XCTAssertEqual(grid.sentinelPosition, expectedSentinelPosition)

        let piece = try XCTUnwrap(grid.get(point: expectedSentinelPosition))
        XCTAssertEqual(piece.level, 8)
    }
}
