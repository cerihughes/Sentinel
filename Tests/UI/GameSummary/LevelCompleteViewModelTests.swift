import XCTest
@testable import Sentinel

final class GameSummaryViewModelTests: XCTestCase {
    private var localDataSource: MockLocalDataSource!
    private var viewModel: GameSummaryViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        localDataSource = .init()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        localDataSource = nil
        try super.tearDownWithError()
    }

    func testNextToken_victory_energy1() {
        storeLevelScore(outcome: .victory, finalEnergy: 1)
        createViewModel()

        XCTAssertEqual(viewModel.nextNavigationToken(), .gamePreview(level: 2))
    }

    func testNextToken_victory_energy4() {
        storeLevelScore(outcome: .victory, finalEnergy: 4)
        createViewModel()

        XCTAssertEqual(viewModel.nextNavigationToken(), .gamePreview(level: 2))
    }

    func testNextToken_victory_energy11() {
        storeLevelScore(outcome: .victory, finalEnergy: 11)
        createViewModel()

        XCTAssertEqual(viewModel.nextNavigationToken(), .gamePreview(level: 3))
    }

    func testNextToken_victory_energy15() {
        storeLevelScore(outcome: .victory, finalEnergy: 15)
        createViewModel()

        XCTAssertEqual(viewModel.nextNavigationToken(), .gamePreview(level: 4))
    }

    func testNextToken_victory_energy16() {
        storeLevelScore(outcome: .victory, finalEnergy: 16)
        createViewModel()

        XCTAssertEqual(viewModel.nextNavigationToken(), .gamePreview(level: 5))
    }

    func testNextToken_defeat() {
        storeLevelScore(outcome: .defeat, finalEnergy: 0)
        createViewModel()

        XCTAssertNil(viewModel)
    }

    func testNextToken_noLevelScore() {
        storeLevelScore(level: 10, outcome: .victory, finalEnergy: 10)
        createViewModel()

        XCTAssertNil(viewModel)
    }

    private func storeLevelScore(level: Int = 1, outcome: LevelScore.Outcome, finalEnergy: Int) {
        let levelScore = LevelScore(outcome: outcome, finalEnergy: finalEnergy)
        let gameScore = GameScore(levelScores: [level: levelScore])
        localDataSource.mockLocalStorage.gameScore = gameScore
    }

    private func createViewModel(level: Int = 1) {
        viewModel = .init(
            level: level,
            worldBuilder: WorldBuilder.createMock(),
            localDataSource: localDataSource
        )
    }
}
