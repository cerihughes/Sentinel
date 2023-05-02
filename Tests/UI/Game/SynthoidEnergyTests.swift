import XCTest
@testable import Sentinel

final class SynthoidEnergyTests: XCTestCase {
    private var synthoidEnergy: SynthoidEnergy!

    override func setUpWithError() throws {
        try super.setUpWithError()
        synthoidEnergy = SynthoidEnergyMonitor()
    }

    override func tearDownWithError() throws {
        synthoidEnergy = nil
        try super.tearDownWithError()
    }

    func testInitialValue() {
        XCTAssertEqual(synthoidEnergy.energy, 10)
    }

    func testAdjust() {
        synthoidEnergy.adjust(delta: 5)
        XCTAssertEqual(synthoidEnergy.energy, 15)
    }

    func testAdjust_negative() {
        synthoidEnergy.adjust(delta: -5)
        XCTAssertEqual(synthoidEnergy.energy, 5)
    }

    func testAdjust_negativeOutOfRange() {
        synthoidEnergy.adjust(delta: -500)
        XCTAssertEqual(synthoidEnergy.energy, 0)
    }

    func testHasEnergy() {
        XCTAssertTrue(synthoidEnergy.has(energy: 9))
        XCTAssertFalse(synthoidEnergy.has(energy: 10))
        XCTAssertFalse(synthoidEnergy.has(energy: 11))
    }

    func testPublisher() {
        let expectation = expectation(description: "Energy Changed")
        expectation.expectedFulfillmentCount = 2 // 1 for initial, 1 for update
        var energy = 0
        let cancellable = synthoidEnergy.energyPublisher
            .receive(on: RunLoop.main)
            .sink { value in
                energy = value
                expectation.fulfill()
            }
        XCTAssertNotNil(cancellable)

        synthoidEnergy.adjust(delta: -8)
        waitForExpectations(timeout: 1)
        XCTAssertEqual(energy, 2)
    }
}
