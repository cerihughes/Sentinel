import XCTest
@testable import Sentinel

final class PlayerOperationsTests: XCTestCase {
    private var terrain: WorldBuilder.Terrain!
    private var operations: WorldBuilder.Operations!
    private var delegate: MockPlayerOperationsDelegate!

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
        terrain = worldBuilder.buildTerrain()
        operations = terrain.createOperations()

        delegate = .init()
        playerOperations.delegate = delegate
    }

    override func tearDownWithError() throws {
        delegate = nil
        operations = nil
        terrain = nil
        try super.tearDownWithError()
    }

    private var playerOperations: PlayerOperations! {
        operations.playerOperations
    }

    private var synthoidEnergy: SynthoidEnergy! {
        operations.synthoidEnergy
    }

    func testNotEnteredScene() {
        XCTAssertFalse(playerOperations.hasEnteredScene())
    }

    func testEnterScene() {
        XCTAssertNil(delegate.lastCameraNode)

        XCTAssertTrue(playerOperations.enterScene())

        XCTAssertNotNil(delegate.lastCameraNode)
        XCTAssertEqual(delegate.lastOperation, .enterScene(.startPosition))
    }

    func testMove() {
        XCTAssertTrue(playerOperations.enterScene())
        let initialCamera = delegate.lastCameraNode

        playerOperations.move(to: .synthoidPosition)

        XCTAssertNotEqual(initialCamera, delegate.lastCameraNode)
        XCTAssertEqual(delegate.lastOperation, .teleport(.synthoidPosition))
    }

    func testMove_emptyPosition() {
        XCTAssertTrue(playerOperations.enterScene())

        delegate.lastCameraNode = nil
        delegate.lastOperation = nil
        playerOperations.move(to: .emptyPosition)

        XCTAssertNil(delegate.lastCameraNode)
        XCTAssertNil(delegate.lastOperation)
    }

    func testMove_invalidPosition() {
        XCTAssertTrue(playerOperations.enterScene())

        delegate.lastCameraNode = nil
        delegate.lastOperation = nil
        playerOperations.move(to: .invalidPosition)

        XCTAssertNil(delegate.lastCameraNode)
        XCTAssertNil(delegate.lastOperation)
    }

    func testMove_notEnteredScene() {
        playerOperations.move(to: .synthoidPosition)
        XCTAssertNil(delegate.lastOperation)
    }

    func testBuild_invalidPosition() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        playerOperations.buildTree(at: .invalidPosition)
        XCTAssertEqual(synthoidEnergy.energy, 10)
        XCTAssertNil(delegate.lastOperation)
    }

    func testAbsorb_emptyPosition() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        playerOperations.absorbTopmostNode(at: .emptyPosition)
        XCTAssertEqual(synthoidEnergy.energy, 10)
        XCTAssertNil(delegate.lastOperation)
    }

    func testAbsorb_invalidPosition() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        playerOperations.absorbTopmostNode(at: .invalidPosition)
        XCTAssertEqual(synthoidEnergy.energy, 10)
        XCTAssertNil(delegate.lastOperation)
    }

    func testBuildTree() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        playerOperations.buildTree(at: .buildPosition)
        XCTAssertEqual(synthoidEnergy.energy, 9)
        XCTAssertEqual(delegate.lastOperation, .build(.tree))
    }

    func testAbsorbTree() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        playerOperations.absorbTopmostNode(at: .treePosition)
        XCTAssertEqual(synthoidEnergy.energy, 11)
        XCTAssertEqual(delegate.lastOperation, .absorb(.tree))
    }

    func testBuildRock() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        playerOperations.buildRock(at: .buildPosition)
        XCTAssertEqual(synthoidEnergy.energy, 8)
        XCTAssertEqual(delegate.lastOperation, .build(.rock))
    }

    func testAbsorbRock() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        playerOperations.absorbTopmostNode(at: .rockPosition)
        XCTAssertEqual(synthoidEnergy.energy, 12)
        XCTAssertEqual(delegate.lastOperation, .absorb(.rock))
    }

    func testBuildSynthoid() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        playerOperations.buildSynthoid(at: .buildPosition)
        XCTAssertEqual(synthoidEnergy.energy, 7)
        XCTAssertEqual(delegate.lastOperation, .build(.synthoid))
    }

    func testAbsorbSynthoid() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        playerOperations.absorbTopmostNode(at: .synthoidPosition)
        XCTAssertEqual(synthoidEnergy.energy, 13)
        XCTAssertEqual(delegate.lastOperation, .absorb(.synthoid))
    }

    func testAbsorbSentry() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        playerOperations.absorbTopmostNode(at: .sentryPosition)
        XCTAssertEqual(synthoidEnergy.energy, 13)
        XCTAssertEqual(delegate.lastOperation, .absorb(.sentry))
    }

    func testAbsorbSentinel() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
        playerOperations.absorbTopmostNode(at: .sentinelPosition)
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
