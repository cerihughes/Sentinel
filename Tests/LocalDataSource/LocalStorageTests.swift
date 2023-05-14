import XCTest

@testable import Sentinel

class LocalStorageTests: XCTestCase {
    private var persistentDataStore: MockPersistentDataStore!
    private var localStorage: LocalStorage!

    override func setUpWithError() throws {
        try super.setUpWithError()
        persistentDataStore = .init()
        localStorage = DefaultLocalStorage(persistentDataStore: persistentDataStore)
    }

    override func tearDownWithError() throws {
        persistentDataStore = nil
        localStorage = nil
        try super.tearDownWithError()
    }

    func testGetGameScoreBeforeSetting() {
        XCTAssertNil(localStorage.gameScore)
    }

    func testSetAndGetGameScore() {
        var gameScore = GameScore()
        gameScore.levelScores[1] = .level1
        gameScore.levelScores[2] = .level2

        localStorage.gameScore = gameScore
        XCTAssertEqual(localStorage.gameScore, gameScore)
    }

    func testWithGarbageData() throws {
        let garbageData = try XCTUnwrap("This is not valid JSON".data(using: .utf8))
        persistentDataStore.set(data: garbageData, forKey: DefaultLocalStorage.gameScoreDataKey)
        XCTAssertNil(localStorage.gameScore)
    }
}

private extension LevelScore {
    static let level1 = LevelScore(
        treesBuilt: 1,
        treesAbsorbed: 2,
        rocksBuilt: 3,
        rocksAbsorbed: 4,
        synthoidsBuilt: 5,
        synthoidsAbsorbed: 6,
        teleports: 7,
        highestPoint: 8,
        sentriesAbsorbed: 9
    )

    static let level2 = LevelScore(
        treesBuilt: 9,
        treesAbsorbed: 8,
        rocksBuilt: 7,
        rocksAbsorbed: 6,
        synthoidsBuilt: 5,
        synthoidsAbsorbed: 4,
        teleports: 3,
        highestPoint: 2,
        sentriesAbsorbed: 1
    )
}
