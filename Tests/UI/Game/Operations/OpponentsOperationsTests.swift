import SceneKit
import XCTest
@testable import Sentinel

final class OpponentsOperationsTests: XCTestCase, TimeMachineTest {
    private var terrain: WorldBuilder.Terrain!
    private var operations: WorldBuilder.Operations!
    private var delegate: MockOpponentsOperationsDelegate!
    var view: SCNView!
    var timeInterval: TimeInterval = 0
    var timeMachineCompletedAllOperations = false

    var timeMachine: TimeMachine! {
        operations.timeMachine
    }

    private var terrainOperations: TerrainOperations! {
        terrain.terrainOperations
    }

    override func tearDownWithError() throws {
        view = nil
        delegate = nil
        operations = nil
        terrain = nil
        try super.tearDownWithError()
    }

    func testDontDetectTree() {
        let builder = GridBuilder.createGridBuilder()
        var grid = builder.buildGrid()
        grid.treePositions.append(.detectionPosition)

        setupScene(grid: grid)

        XCTAssertEqual(terrainOperations.grid.treePositions, [.detectionPosition])
        XCTAssertEqual(delegate.opponentsOperationsDidAbsorbCalls, 0)

        runDetectionTest()

        // There should be no change in the tree positions
        XCTAssertEqual(terrainOperations.grid.treePositions, [.detectionPosition])
        XCTAssertEqual(delegate.opponentsOperationsDidAbsorbCalls, 0)
    }

    func testDetectTreeOnRock() {
        let builder = GridBuilder.createGridBuilder()
        var grid = builder.buildGrid()
        grid.addRock(at: .detectionPosition)
        grid.treePositions.append(.detectionPosition)

        setupScene(grid: grid)

        XCTAssertEqual(terrainOperations.grid.allRockPositions(), [.detectionPosition])
        XCTAssertEqual(terrainOperations.grid.treePositions, [.detectionPosition])
        XCTAssertEqual(delegate.opponentsOperationsDidAbsorbCalls, 0)

        runDetectionTest()

        // The tree should have been detected and absorbed, creating another tree in the process (somewhere else)
        XCTAssertEqual(terrainOperations.grid.allRockPositions(), [.detectionPosition])
        XCTAssertEqual(terrainOperations.grid.treePositions.count, 1)
        XCTAssertNotEqual(terrainOperations.grid.treePositions, [.detectionPosition])
        XCTAssertEqual(delegate.opponentsOperationsDidAbsorbCalls, 1)
    }

    func testDetectRock() {
        let builder = GridBuilder.createGridBuilder()
        var grid = builder.buildGrid()
        grid.addRock(at: .detectionPosition)

        setupScene(grid: grid)

        XCTAssertEqual(terrainOperations.grid.allRockPositions(), [.detectionPosition])
        XCTAssertEqual(terrainOperations.grid.treePositions, [])
        XCTAssertEqual(delegate.opponentsOperationsDidAbsorbCalls, 0)

        runDetectionTest()

        // A rock should have been detected and absorbed down to a tree, creating another tree in the process
        XCTAssertEqual(terrainOperations.grid.allRockPositions(), [])
        XCTAssertEqual(terrainOperations.grid.treePositions.count, 2)
        XCTAssertEqual(delegate.opponentsOperationsDidAbsorbCalls, 1)
    }

    func testDetectSynthoid() {
        let builder = GridBuilder.createGridBuilder()
        var grid = builder.buildGrid()
        grid.synthoidPositions.append(.detectionPosition)

        setupScene(grid: grid)

        XCTAssertEqual(terrainOperations.grid.allRockPositions(), [])
        XCTAssertEqual(terrainOperations.grid.synthoidPositions, [.startPosition, .detectionPosition])
        XCTAssertEqual(delegate.opponentsOperationsDidAbsorbCalls, 0)

        runDetectionTest()

        // A synthoid should have been detected and absorbed down to a rock, creating another tree in the process
        XCTAssertEqual(terrainOperations.grid.allRockPositions(), [.detectionPosition])
        XCTAssertEqual(terrainOperations.grid.synthoidPositions, [.startPosition])
        XCTAssertEqual(terrainOperations.grid.treePositions.count, 1)
        XCTAssertEqual(delegate.opponentsOperationsDidAbsorbCalls, 1)
    }

    func testDetectSynthoidOnRock() {
        let builder = GridBuilder.createGridBuilder()
        var grid = builder.buildGrid()
        grid.addRock(at: .detectionPosition)
        grid.synthoidPositions.append(.detectionPosition)

        setupScene(grid: grid)

        XCTAssertEqual(terrainOperations.grid.allRockPositions(), [.detectionPosition])
        XCTAssertEqual(terrainOperations.grid.rockCount(at: .detectionPosition), 1)
        XCTAssertEqual(terrainOperations.grid.synthoidPositions, [.startPosition, .detectionPosition])
        XCTAssertEqual(delegate.opponentsOperationsDidAbsorbCalls, 0)

        runDetectionTest()

        // A synthoid should have been detected and absorbed down to a rock, creating another tree in the process
        XCTAssertEqual(terrainOperations.grid.allRockPositions(), [.detectionPosition])
        XCTAssertEqual(terrainOperations.grid.rockCount(at: .detectionPosition), 2)
        XCTAssertEqual(terrainOperations.grid.synthoidPositions, [.startPosition])
        XCTAssertEqual(terrainOperations.grid.treePositions.count, 1)
        XCTAssertEqual(delegate.opponentsOperationsDidAbsorbCalls, 1)
    }

    func testDetectPlayer() {
        let builder = GridBuilder.createGridBuilder()
        var grid = builder.buildGrid()
        grid.synthoidPositions.append(.detectionPosition)

        setupScene(grid: grid)

        XCTAssertNil(delegate.lastDetectOpponent)
        XCTAssertEqual(delegate.opponentsOperationsDidDepleteEnergyCalls, 0)

        operations.playerOperations.move(to: .detectionPosition)
        runDetectionTest()

        // Synthoid should be detected, although energy depletion doesn't happen on the 1st iteration
        XCTAssertNotNil(delegate.lastDetectOpponent)
        XCTAssertEqual(delegate.opponentsOperationsDidDepleteEnergyCalls, 0)

        runAllTimeMachineOperationsAgain()
        XCTAssertNotNil(delegate.lastDetectOpponent)
        XCTAssertEqual(delegate.opponentsOperationsDidDepleteEnergyCalls, 1)
    }

    private func setupScene(grid: Grid) {
        let worldBuilder = WorldBuilder.createMock(grid: grid)
        terrain = worldBuilder.buildTerrain()
        operations = terrain.createOperations()
        XCTAssertTrue(operations.playerOperations.enterScene())

        delegate = .init()
        operations.opponentsOperations.delegate = delegate

        view = SCNView(frame: .init(x: 0, y: 0, width: 200, height: 200))

        view.scene = terrain.scene
        view.backgroundColor = UIColor.black
        view.pointOfView = terrain.initialCameraNode
    }

    private func runDetectionTest() {
        timeMachine.add(timeInterval: 2.0) { [weak self] _, _, _ in
            self?.timeMachineCompletedAllOperations = true
            return true
        }

        timeMachine.start()

        runAllTimeMachineOperationsAgain()
    }

    func runAllTimeMachineOperationsAgain() {
        timeMachineCompletedAllOperations = false
        while !timeMachineCompletedAllOperations {
            pumpRunLoop()
        }
    }
}

private extension GridPoint {
    static let detectionPosition = GridPoint(x: 4, z: 2)
}
