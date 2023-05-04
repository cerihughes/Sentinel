import XCTest
@testable import Sentinel

final class GameViewModelTests: XCTestCase {
    private var viewModel: GameViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let levelConfiguration = MockLevelConfiguration()
        let nodePositioning = NodePositioning(gridWidth: levelConfiguration.gridWidth,
                                              gridDepth: levelConfiguration.gridDepth,
                                              floorSize: floorSize)

        let materialFactory = DefaultMaterialFactory(level: levelConfiguration.level)
        let nodeFactory = NodeFactory(nodePositioning: nodePositioning,
                                      detectionRadius: levelConfiguration.opponentDetectionRadius * floorSize,
                                      materialFactory: materialFactory)
        viewModel = GameViewModel(
            levelConfiguration: levelConfiguration,
            gameScore: GameScore(),
            nodeFactory: nodeFactory,
            world: MockWorld()
        )
    }

    override func tearDownWithError() throws {
        viewModel = nil
        try super.tearDownWithError()
    }

    func testTreeBuilt() {
        let delegate = MockGameViewModelDelegate()
        viewModel.delegate = delegate
        viewModel.playerOperations(viewModel.playerOperations, didPerform: .build(.tree))
        XCTAssertEqual(viewModel.levelScore.treesBuilt, 1)
    }

    func testSentinelAbsorbed() {
        let delegate = MockGameViewModelDelegate()
        viewModel.delegate = delegate
        viewModel.playerOperations(viewModel.playerOperations, didPerform: .absorb(.sentinel))
        XCTAssertEqual(delegate.endState, .victory)
    }
}
