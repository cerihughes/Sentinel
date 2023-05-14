import XCTest
@testable import Sentinel

final class PlayerOperationsTests: XCTestCase {
    private var built: WorldBuilder.Built!
    private var delegate: MockPlayerOperationsDelegate!
    private var operations: PlayerOperations!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let builder = GridBuilder.createGridBuilder()
        var grid = builder.buildGrid()
        grid.treePositions.append(.treePosition)
        grid.addRock(at: .rockPosition)
        grid.synthoidPositions.append(.synthoidPosition)
        grid.sentryPositions.append(.sentryPosition)
        print(grid.contentsDescription)
        let worldBuilder = WorldBuilder.createMock(grid: grid)
        built = worldBuilder.build()
        operations = built.playerOperations

        delegate = .init()
        operations.delegate = delegate
    }

    override func tearDownWithError() throws {
        operations = nil
        built = nil
        try super.tearDownWithError()
    }

    private var synthoidEnergy: SynthoidEnergy! {
        built.synthoidEnergy
    }

    func testNotEnteredScene() {
        XCTAssertFalse(operations.hasEnteredScene())
    }

    func testEnterScene() {
        XCTAssertNil(delegate.lastCameraNode)

        XCTAssertTrue(operations.enterScene())

        XCTAssertNotNil(delegate.lastCameraNode)
        XCTAssertEqual(delegate.lastOperation, .enterScene(.startPosition))
    }

    func testMove() {
        XCTAssertTrue(operations.enterScene())
        let initialCamera = delegate.lastCameraNode

        operations.move(to: .synthoidPosition)

        XCTAssertNotEqual(initialCamera, delegate.lastCameraNode)
        XCTAssertEqual(delegate.lastOperation, .teleport(.synthoidPosition))
    }

    func testMove_emptyPosition() {
        XCTAssertTrue(operations.enterScene())

        delegate.lastCameraNode = nil
        delegate.lastOperation = nil
        operations.move(to: .emptyPosition)

        XCTAssertNil(delegate.lastCameraNode)
        XCTAssertNil(delegate.lastOperation)
    }

    func testMove_invalidPosition() {
        XCTAssertTrue(operations.enterScene())

        delegate.lastCameraNode = nil
        delegate.lastOperation = nil
        operations.move(to: .invalidPosition)

        XCTAssertNil(delegate.lastCameraNode)
        XCTAssertNil(delegate.lastOperation)
    }

    func testMove_notEnteredScene() {
        operations.move(to: .synthoidPosition)
        XCTAssertNil(delegate.lastOperation)
    }

    func testBuild_invalidPosition() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        operations.buildTree(at: .invalidPosition)
        XCTAssertEqual(synthoidEnergy.energy, 10)
        XCTAssertNil(delegate.lastOperation)
    }

    func testAbsorb_emptyPosition() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        operations.absorbTopmostNode(at: .emptyPosition)
        XCTAssertEqual(synthoidEnergy.energy, 10)
        XCTAssertNil(delegate.lastOperation)
    }

    func testAbsorb_invalidPosition() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        operations.absorbTopmostNode(at: .invalidPosition)
        XCTAssertEqual(synthoidEnergy.energy, 10)
        XCTAssertNil(delegate.lastOperation)
    }

    func testBuildTree() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        operations.buildTree(at: .buildPosition)
        XCTAssertEqual(synthoidEnergy.energy, 9)
        XCTAssertEqual(delegate.lastOperation, .build(.tree))
    }

    func testAbsorbTree() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        operations.absorbTopmostNode(at: .treePosition)
        XCTAssertEqual(synthoidEnergy.energy, 11)
        XCTAssertEqual(delegate.lastOperation, .absorb(.tree))
    }

    func testBuildRock() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        operations.buildRock(at: .buildPosition)
        XCTAssertEqual(synthoidEnergy.energy, 8)
        XCTAssertEqual(delegate.lastOperation, .build(.rock))
    }

    func testAbsorbRock() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        operations.absorbTopmostNode(at: .rockPosition)
        XCTAssertEqual(synthoidEnergy.energy, 12)
        XCTAssertEqual(delegate.lastOperation, .absorb(.rock))
    }

    func testBuildSynthoid() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        operations.buildSynthoid(at: .buildPosition)
        XCTAssertEqual(synthoidEnergy.energy, 7)
        XCTAssertEqual(delegate.lastOperation, .build(.synthoid))
    }

    func testAbsorbSynthoid() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        operations.absorbTopmostNode(at: .synthoidPosition)
        XCTAssertEqual(synthoidEnergy.energy, 13)
        XCTAssertEqual(delegate.lastOperation, .absorb(.synthoid))
    }

    func testAbsorbSentry() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        operations.absorbTopmostNode(at: .sentryPosition)
        XCTAssertEqual(synthoidEnergy.energy, 13)
        XCTAssertEqual(delegate.lastOperation, .absorb(.sentry))
    }

    func testAbsorbSentinel() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        operations.absorbTopmostNode(at: .sentinelPosition)
        XCTAssertEqual(synthoidEnergy.energy, 14)
        XCTAssertEqual(delegate.lastOperation, .absorb(.sentinel))
    }
}

private extension GridPoint {
    static let treePosition = GridPoint(x: 0, z: 0)
    static let rockPosition = GridPoint(x: 1, z: 0)
    static let synthoidPosition = GridPoint(x: 2, z: 0)
    static let sentryPosition = GridPoint(x: 3, z: 0)
    static let emptyPosition = GridPoint(x: 4, z: 0)
    static let buildPosition = GridPoint(x: 4, z: 2)
    static let invalidPosition = GridPoint(x: 400, z: 200)
}
