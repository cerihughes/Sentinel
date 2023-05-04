import XCTest
@testable import Sentinel

final class GameViewModelTests: XCTestCase {
    private var viewModel: GameViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = GameViewModel(worldBuilder: WorldBuilder.createMock(), gameScore: GameScore())
    }

    override func tearDownWithError() throws {
        viewModel = nil
        try super.tearDownWithError()
    }

    func testInitiallyHasNoTeleportsAfterEnteringScene() {
        viewModel.built.playerOperations.enterScene()
        XCTAssertEqual(viewModel.levelScore.teleports, 0)
    }

    func testTreeBuilt() {
        viewModel.playerOperations(viewModel.built.playerOperations, didPerform: .build(.tree))
        XCTAssertEqual(viewModel.levelScore.treesBuilt, 1)
    }

    func testSentinelAbsorbed() {
        let delegate = MockGameViewModelDelegate()
        viewModel.delegate = delegate
        viewModel.playerOperations(viewModel.built.playerOperations, didPerform: .absorb(.sentinel))
        XCTAssertEqual(delegate.endState, .victory)
    }
}
