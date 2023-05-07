import SceneKit
import XCTest
@testable import Sentinel

protocol TimeMachineTest: XCTestCase {
    var view: SCNView! { get }
    var timeMachine: TimeMachine! { get }
    var timeInterval: TimeInterval { get set }
}

extension TimeMachineTest {
    func pumpRunLoop(timeDelta: TimeInterval = 0.10001) { // use a value slightly more than 1 to avoid ulp issues
        timeMachine.handle(currentTimeInterval: timeInterval, renderer: view)
        timeInterval += timeDelta
    }
}

final class TimeMachineTests: XCTestCase, TimeMachineTest {
    var view: SCNView!
    var timeMachine: TimeMachine!
    var timeInterval: TimeInterval = 0

    override func setUpWithError() throws {
        try super.setUpWithError()
        view = SCNView(frame: .init(x: 0, y: 0, width: 200, height: 200))
        timeMachine = TimeMachine()
    }

    override func tearDownWithError() throws {
        view = nil
        try super.tearDownWithError()
    }

    func testFunctionsRunInOrder() {
        var numbers = [Int]()

        _ = timeMachine.add(timeInterval: 1.0) { _, _, _ in
            numbers.append(1)
            return true
        }

        _ = timeMachine.add(timeInterval: 1.0) { _, _, _ in
            numbers.append(2)
            return true
        }

        _ = timeMachine.add(timeInterval: 1.0) { _, _, _ in
            numbers.append(3)
            return true
        }

        _ = timeMachine.add(timeInterval: 1.0) { _, _, _ in
            numbers.append(4)
            return true
        }

        timeMachine.start()

        pumpRunLoop()
        XCTAssertEqual(numbers, [1])
        pumpRunLoop()
        XCTAssertEqual(numbers, [1, 2])
        pumpRunLoop()
        XCTAssertEqual(numbers, [1, 2, 3])
        pumpRunLoop()
        XCTAssertEqual(numbers, [1, 2, 3, 4])
    }

    func testFunctionsRunWithDifferentTimeIntervals() {
        var numbers = [Int]()

        _ = timeMachine.add(timeInterval: 1.2) { _, _, _ in
            numbers.append(1)
            return true
        }

        _ = timeMachine.add(timeInterval: 0.8) { _, _, _ in
            numbers.append(2)
            return true
        }

        _ = timeMachine.add(timeInterval: 0.4) { _, _, _ in
            numbers.append(3)
            return true
        }

        timeMachine.start()

        pumpRunLoop() // 0.1
        XCTAssertEqual(numbers, [1]) // 1 will next trigger after 1.3
        pumpRunLoop() // 0.2
        XCTAssertEqual(numbers, [1, 2]) // 2 will next trigger after 1.0
        pumpRunLoop() // 0.3
        XCTAssertEqual(numbers, [1, 2, 3]) // 3 will next trigger after 0.7
        pumpRunLoop() // 0.4
        XCTAssertEqual(numbers, [1, 2, 3])
        pumpRunLoop() // 0.5
        XCTAssertEqual(numbers, [1, 2, 3])
        pumpRunLoop() // 0.6
        XCTAssertEqual(numbers, [1, 2, 3])
        pumpRunLoop() // 0.7
        XCTAssertEqual(numbers, [1, 2, 3, 3]) // 3 will next trigger after 1.1
        pumpRunLoop() // 0.8
        XCTAssertEqual(numbers, [1, 2, 3, 3])
        pumpRunLoop() // 0.9
        XCTAssertEqual(numbers, [1, 2, 3, 3])
        pumpRunLoop() // 1.0
        XCTAssertEqual(numbers, [1, 2, 3, 3, 2]) // 2 will next trigger after 1.8
        pumpRunLoop() // 1.1
        XCTAssertEqual(numbers, [1, 2, 3, 3, 2, 3]) // 3 will next trigger after 1.5
        pumpRunLoop() // 1.2
        XCTAssertEqual(numbers, [1, 2, 3, 3, 2, 3])
        pumpRunLoop() // 1.3
        XCTAssertEqual(numbers, [1, 2, 3, 3, 2, 3, 1]) // 1 will next trigger after 2.5
    }
}
