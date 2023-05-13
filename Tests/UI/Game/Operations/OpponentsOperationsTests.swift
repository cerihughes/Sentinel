import SceneKit
import XCTest
@testable import Sentinel

final class OpponentsOperationsTests: XCTestCase, TimeMachineTest {
    private var worldBuilder: WorldBuilder!
    private var built: WorldBuilder.Built!
    private var operations: OpponentsOperations!
    var view: SCNView!
    var timeInterval: TimeInterval = 0

    var timeMachine: TimeMachine! {
        built.timeMachine
    }

    override func tearDownWithError() throws {
        view = nil
        operations = nil
        built = nil
        worldBuilder = nil
        try super.tearDownWithError()
    }

    func testDontDetectTree() {
        let builder = GridBuilder.createGridBuilder()
        var grid = builder.buildGrid()
        grid.treePositions.append(.detectionPosition)

        setupScene(grid: grid)

        XCTAssertEqual(built.terrainOperations.grid.treePositions, [.detectionPosition])

        runDetectionTest()

        // There should be no change in the tree positions
        XCTAssertEqual(built.terrainOperations.grid.treePositions, [.detectionPosition])
    }

    func testDetectTreeOnRock() {
        let builder = GridBuilder.createGridBuilder()
        var grid = builder.buildGrid()
        grid.addRock(at: .detectionPosition)
        grid.treePositions.append(.detectionPosition)

        setupScene(grid: grid)

        XCTAssertEqual(built.terrainOperations.grid.allRockPositions(), [.detectionPosition])
        XCTAssertEqual(built.terrainOperations.grid.treePositions, [.detectionPosition])

        runDetectionTest()

        // The tree should have been detected and absorbed, creating another tree in the process (somewhere else)
        XCTAssertEqual(built.terrainOperations.grid.allRockPositions(), [.detectionPosition])
        XCTAssertEqual(built.terrainOperations.grid.treePositions.count, 1)
        XCTAssertNotEqual(built.terrainOperations.grid.treePositions, [.detectionPosition])
    }

    func testDetectRock() {
        let builder = GridBuilder.createGridBuilder()
        var grid = builder.buildGrid()
        grid.addRock(at: .detectionPosition)

        setupScene(grid: grid)

        XCTAssertEqual(built.terrainOperations.grid.allRockPositions(), [.detectionPosition])
        XCTAssertEqual(built.terrainOperations.grid.treePositions, [])

        runDetectionTest()

        // A rock should have been detected and absorbed down to a tree, creating another tree in the process
        XCTAssertEqual(built.terrainOperations.grid.allRockPositions(), [])
        XCTAssertEqual(built.terrainOperations.grid.treePositions.count, 2)
    }

    func testDetectSynthoid() {
        let builder = GridBuilder.createGridBuilder()
        var grid = builder.buildGrid()
        grid.synthoidPositions.append(.detectionPosition)

        setupScene(grid: grid)

        XCTAssertEqual(built.terrainOperations.grid.allRockPositions(), [])
        XCTAssertEqual(built.terrainOperations.grid.synthoidPositions, [.startPosition, .detectionPosition])

        runDetectionTest()

        // A synthoid should have been detected and absorbed down to a rock, creating another tree in the process
        XCTAssertEqual(built.terrainOperations.grid.allRockPositions(), [.detectionPosition])
        XCTAssertEqual(built.terrainOperations.grid.synthoidPositions, [.startPosition])
        XCTAssertEqual(built.terrainOperations.grid.treePositions.count, 1)
    }

    func testDetectSynthoidOnRock() {
        let builder = GridBuilder.createGridBuilder()
        var grid = builder.buildGrid()
        grid.addRock(at: .detectionPosition)
        grid.synthoidPositions.append(.detectionPosition)

        setupScene(grid: grid)

        XCTAssertEqual(built.terrainOperations.grid.allRockPositions(), [.detectionPosition])
        XCTAssertEqual(built.terrainOperations.grid.rockCount(at: .detectionPosition), 1)
        XCTAssertEqual(built.terrainOperations.grid.synthoidPositions, [.startPosition, .detectionPosition])

        runDetectionTest()

        // A synthoid should have been detected and absorbed down to a rock, creating another tree in the process
        XCTAssertEqual(built.terrainOperations.grid.allRockPositions(), [.detectionPosition])
        XCTAssertEqual(built.terrainOperations.grid.rockCount(at: .detectionPosition), 2)
        XCTAssertEqual(built.terrainOperations.grid.synthoidPositions, [.startPosition])
        XCTAssertEqual(built.terrainOperations.grid.treePositions.count, 1)
    }

    private func setupScene(grid: Grid) {
        worldBuilder = WorldBuilder.createMock(grid: grid)
        built = worldBuilder.build()
        operations = built.opponentsOperations
        view = SCNView(frame: .init(x: 0, y: 0, width: 200, height: 200))

        view.scene = built.scene
        view.backgroundColor = UIColor.black
        view.pointOfView = built.initialCameraNode
    }

    private func runDetectionTest() {
        var timeMachineCompletedAllOperations = false
        _ = timeMachine.add(timeInterval: 2.0) { _, _, _ in
            timeMachineCompletedAllOperations = true
            return true
        }

        timeMachine.start()
        XCTAssertTrue(built.playerOperations.enterScene())

        while !timeMachineCompletedAllOperations {
            pumpRunLoop()
        }
    }

}

private extension GridPoint {
    static let startPosition = GridPoint(x: 0, z: 2)
    static let sentinelPosition = GridPoint(x: 2, z: 2)
    static let detectionPosition = GridPoint(x: 4, z: 2)
}

private extension GridBuilder {
    static func createGridBuilder() -> GridBuilder {
        let builder = GridBuilder(width: 5, depth: 5)
        builder.startPosition = .startPosition
        builder.synthoidPositions.append(.startPosition)
        builder.sentinelPosition = .sentinelPosition
        return builder
    }
}
