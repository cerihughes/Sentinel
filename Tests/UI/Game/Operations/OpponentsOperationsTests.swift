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
        operations.timeMachine
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        let grid = Grid.createTestGrid()
        worldBuilder = WorldBuilder.createMock(grid: grid)
        built = worldBuilder.build()
        operations = built.opponentsOperations
        view = SCNView(frame: .init(x: 0, y: 0, width: 200, height: 200))

        view.scene = worldBuilder.world.scene
        view.backgroundColor = UIColor.black
        view.pointOfView = built.initialCameraNode
    }

    override func tearDownWithError() throws {
        view = nil
        operations = nil
        built = nil
        worldBuilder = nil
        try super.tearDownWithError()
    }

    func testGenerateTree() {
        var timeMachineCompletedAllOperations = false
        _ = operations.timeMachine.add(timeInterval: 2.0) { _, _, _ in
            timeMachineCompletedAllOperations = true
            return true
        }

        XCTAssertEqual(built.terrainOperations.grid.rockPositions.count, 1)
        XCTAssertEqual(built.terrainOperations.grid.treePositions.count, 0)

        operations.timeMachine.start()
        XCTAssertTrue(built.playerOperations.enterScene())

        while !timeMachineCompletedAllOperations {
            pumpRunLoop()
        }

        // A rock should have been detected and absorbed down to a tree, creating another tree in the process
        XCTAssertEqual(built.terrainOperations.grid.rockPositions.count, 0)
        XCTAssertEqual(built.terrainOperations.grid.treePositions.count, 2)
    }
}

private extension Grid {
    static func createTestGrid() -> Grid {
        let builder = GridBuilder(width: 5, depth: 5)
        let startPosition = GridPoint(x: 0, z: 2)
        builder.startPosition = startPosition
        builder.synthoidPositions.append(startPosition)
        builder.sentinelPosition = .init(x: 2, z: 2)
        var grid = builder.buildGrid()
        grid.rockPositions.append(.init(x: 4, z: 2))
        return grid
    }
}
