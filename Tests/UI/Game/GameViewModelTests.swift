import XCTest
@testable import Sentinel

final class GameViewModelTests: XCTestCase {
    private var localDataSource: MockLocalDataSource!
    private var audioManager: MockAudioManager!
    private var viewModel: GameViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        localDataSource = .init()
        audioManager = .init()
        viewModel = GameViewModel(
            level: 1,
            worldBuilder: WorldBuilder.createMock(),
            localDataSource: localDataSource,
            audioManager: audioManager
        )
    }

    override func tearDownWithError() throws {
        viewModel = nil
        audioManager = nil
        localDataSource = nil
        try super.tearDownWithError()
    }

    func testInitiallyHasNoTeleportsAfterEnteringScene() {
        XCTAssertTrue(viewModel.operations.playerOperations.enterScene())
        XCTAssertEqual(viewModel.levelScore.teleports, 0)
    }

    func testTreesBuilt() {
        playerOperations.buildTree(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.treesBuilt, 1)
        playerOperations.buildTree(at: .floor2)
        XCTAssertEqual(viewModel.levelScore.treesBuilt, 2)
    }

    func testTreeNotBuiltOnSlope() {
        playerOperations.buildTree(at: .slope)
        XCTAssertEqual(viewModel.levelScore.treesBuilt, 0)
    }

    func testTreeNotBuiltOnSentinel() {
        playerOperations.buildTree(at: .sentinel)
        XCTAssertEqual(viewModel.levelScore.treesBuilt, 0)
    }

    func testTreeNotBuiltOnTree() {
        playerOperations.buildTree(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.treesBuilt, 1)
        playerOperations.buildTree(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.treesBuilt, 1)
    }

    func testTreeNotBuiltOnSynthoid() {
        playerOperations.buildSynthoid(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.synthoidsBuilt, 1)
        playerOperations.buildTree(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.treesBuilt, 0)
    }

    func testRocksBuilt() {
        playerOperations.buildRock(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.rocksBuilt, 1)
        playerOperations.buildRock(at: .floor2)
        XCTAssertEqual(viewModel.levelScore.rocksBuilt, 2)
    }

    func testRockNotBuiltOnSlope() {
        playerOperations.buildRock(at: .slope)
        XCTAssertEqual(viewModel.levelScore.rocksBuilt, 0)
    }

    func testRockNotBuiltOnSentinel() {
        playerOperations.buildRock(at: .sentinel)
        XCTAssertEqual(viewModel.levelScore.rocksBuilt, 0)
    }

    func testRockNotBuiltOnTree() {
        playerOperations.buildTree(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.treesBuilt, 1)
        playerOperations.buildRock(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.rocksBuilt, 0)
    }

    func testRockNotBuiltOnSynthoid() {
        playerOperations.buildSynthoid(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.synthoidsBuilt, 1)
        playerOperations.buildRock(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.rocksBuilt, 0)
    }

    func testRockStacksBuilt() {
        playerOperations.buildRock(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.rocksBuilt, 1)
        playerOperations.buildRock(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.rocksBuilt, 2)
        playerOperations.buildRock(at: .floor2)
        XCTAssertEqual(viewModel.levelScore.rocksBuilt, 3)
        playerOperations.buildRock(at: .floor2)
        XCTAssertEqual(viewModel.levelScore.rocksBuilt, 4)
    }

    func testTreeBuiltOnRock() {
        playerOperations.buildRock(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.rocksBuilt, 1)
        playerOperations.buildTree(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.treesBuilt, 1)
    }

    func testSynthoidsBuilt() {
        playerOperations.buildSynthoid(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.synthoidsBuilt, 1)
        playerOperations.buildSynthoid(at: .floor2)
        XCTAssertEqual(viewModel.levelScore.synthoidsBuilt, 2)
    }

    func testSynthoidNotBuiltOnSlope() {
        playerOperations.buildSynthoid(at: .slope)
        XCTAssertEqual(viewModel.levelScore.synthoidsBuilt, 0)
    }

    func testSynthoidNotBuiltOnSentinel() {
        playerOperations.buildSynthoid(at: .sentinel)
        XCTAssertEqual(viewModel.levelScore.synthoidsBuilt, 0)
    }

    func testSynthoidNotBuiltOnTree() {
        playerOperations.buildTree(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.treesBuilt, 1)
        playerOperations.buildSynthoid(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.synthoidsBuilt, 0)
    }

    func testSynthoidNotBuiltOnSynthoid() {
        playerOperations.buildSynthoid(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.synthoidsBuilt, 1)
        playerOperations.buildSynthoid(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.synthoidsBuilt, 1)
    }

    func testSynthoidBuiltOnRock() {
        playerOperations.buildRock(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.rocksBuilt, 1)
        playerOperations.buildSynthoid(at: .floor1)
        XCTAssertEqual(viewModel.levelScore.synthoidsBuilt, 1)
    }

    func testSentinelAbsorbed() {
        let delegate = MockGameViewModelDelegate()
        viewModel.delegate = delegate
        viewModel.playerOperations(playerOperations, didPerform: .absorb(.sentinel))
        XCTAssertEqual(delegate.lastOutcome, .victory)
    }

    func testTeleportOntoFloor() throws {
        playerOperations.buildSynthoid(at: .floor1)

        XCTAssertTrue(playerOperations.enterScene())
        XCTAssertEqual(viewModel.levelScore.highestPoint, 0)

        playerOperations.move(to: .floor1)
        XCTAssertEqual(viewModel.levelScore.highestPoint, 0)
    }

    func testTeleportOntoRock() throws {
        playerOperations.buildRock(at: .floor2)
        playerOperations.buildSynthoid(at: .floor2)

        XCTAssertTrue(playerOperations.enterScene())
        XCTAssertEqual(viewModel.levelScore.highestPoint, 0)

        playerOperations.move(to: .floor2)
        XCTAssertEqual(viewModel.levelScore.highestPoint, 0)
    }

    func testTeleportOntoRockStack() throws {
        playerOperations.buildRock(at: .floor3)
        playerOperations.buildRock(at: .floor3)
        playerOperations.buildSynthoid(at: .floor3)

        XCTAssertTrue(playerOperations.enterScene())
        XCTAssertEqual(viewModel.levelScore.highestPoint, 0)

        playerOperations.move(to: .floor3)
        XCTAssertEqual(viewModel.levelScore.highestPoint, 1)
    }

    func testNextToken_gameInProgress() {
        XCTAssertNil(viewModel.nextNavigationToken())
    }

    func testNextToken_victory() {
        let outcomeExpectation = expectation(description: "Level Finished")
        let delegate = MockGameViewModelDelegate()
        delegate.outcomeExpectation = outcomeExpectation

        viewModel.delegate = delegate
        viewModel.playerOperations(playerOperations, didPerform: .absorb(.sentinel))

        waitForExpectations(timeout: 1)
        XCTAssertEqual(viewModel.nextNavigationToken(), .gameSummary(level: 1))
    }

    func testNextToken_defeat() {
        let outcomeExpectation = expectation(description: "Level Finished")
        let delegate = MockGameViewModelDelegate()
        delegate.outcomeExpectation = outcomeExpectation

        viewModel.delegate = delegate
        viewModel.operations.synthoidEnergy.adjust(delta: -100)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(delegate.lastOutcome, .defeat)
        XCTAssertNil(viewModel.nextNavigationToken())
    }
}

private extension GameViewModelTests {
    var playerOperations: PlayerOperations! {
        viewModel.operations.playerOperations
    }
}

private extension GridPoint {
    static let floor1 = GridPoint(x: 0, z: 7)
    static let floor2 = GridPoint(x: 1, z: 7)
    static let floor3 = GridPoint(x: 2, z: 7)
    static let slope = GridPoint(x: 7, z: 2)
    static let sentinel = GridPoint(x: 7, z: 4)
}
