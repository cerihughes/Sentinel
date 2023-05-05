import XCTest
@testable import Sentinel

final class CaseIterableExtensionTests: XCTestCase {

    func testAllCasesExcept() {
        let allExceptAlga: [Plant] = [.fungus, .moss, .fern, .conifer, .floweringPlant]
        let allExceptMoss: [Plant] = [.alga, .fungus, .fern, .conifer, .floweringPlant]
        let allExceptFloweringPlant: [Plant] = [.alga, .fungus, .moss, .fern, .conifer]

        XCTAssertEqual(Plant.allCases(except: .alga), allExceptAlga)
        XCTAssertEqual(Plant.allCases(except: .moss), allExceptMoss)
        XCTAssertEqual(Plant.allCases(except: .floweringPlant), allExceptFloweringPlant)
    }
}

private enum Plant: CaseIterable {
    case alga, fungus, moss, fern, conifer, floweringPlant
}
