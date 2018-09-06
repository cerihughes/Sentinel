import XCTest

class GridPointTests: XCTestCase {

    let epsilon: Float = 0.0001

    func testAdjacentPointToRight() {
        let pointA = GridPoint(x: 0, z: 0)
        let pointB = GridPoint(x: 1, z: 0)

        XCTAssertEqual(pointA.angle(to: pointB), Float.pi * 1.5, accuracy: epsilon)
    }

    func testAdjacentPointToFrontRight() {
        let pointA = GridPoint(x: 0, z: 0)
        let pointB = GridPoint(x: 1, z: 1)

        XCTAssertEqual(pointA.angle(to: pointB), Float.pi * 1.25 , accuracy: epsilon)
    }

    func testAdjacentPointToFront() {
        let pointA = GridPoint(x: 0, z: 0)
        let pointB = GridPoint(x: 0, z: 1)

        XCTAssertEqual(pointA.angle(to: pointB), Float.pi, accuracy: epsilon)
    }

    func testAdjacentPointToFrontLeft() {
        let pointA = GridPoint(x: 0, z: 0)
        let pointB = GridPoint(x: -1, z: 1)

        XCTAssertEqual(pointA.angle(to: pointB), Float.pi * 0.75, accuracy: epsilon)
    }

    func testAdjacentPointToLeft() {
        let pointA = GridPoint(x: 0, z: 0)
        let pointB = GridPoint(x: -1, z: 0)

        XCTAssertEqual(pointA.angle(to: pointB), Float.pi * 0.5, accuracy: epsilon)
    }

    func testAdjacentPointToBackLeft() {
        let pointA = GridPoint(x: 0, z: 0)
        let pointB = GridPoint(x: -1, z: -1)

        XCTAssertEqual(pointA.angle(to: pointB), Float.pi * 0.25 , accuracy: epsilon)
    }

    func testAdjacentToBack() {
        let pointA = GridPoint(x: 0, z: 0)
        let pointB = GridPoint(x: 0, z: -1)

        XCTAssertEqual(pointA.angle(to: pointB), 0.0, accuracy: epsilon)
    }

    func testAdjacentPointToBackRight() {
        let pointA = GridPoint(x: 0, z: 0)
        let pointB = GridPoint(x: 1, z: -1)

        XCTAssertEqual(pointA.angle(to: pointB), Float.pi * 1.75, accuracy: epsilon)
    }

    func testPointToRight() {
        let pointA = GridPoint(x: -20, z: -10)
        let pointB = GridPoint(x: 100, z: -10)

        XCTAssertEqual(pointA.angle(to: pointB), Float.pi * 1.5, accuracy: epsilon)
    }

    func testPointToFront() {
        let pointA = GridPoint(x: 133, z: 35)
        let pointB = GridPoint(x: 133, z: 744)

        XCTAssertEqual(pointA.angle(to: pointB), Float.pi, accuracy: epsilon)
    }

    func testPointToLeft() {
        let pointA = GridPoint(x: -5, z: 50)
        let pointB = GridPoint(x: -10, z: 50)

        XCTAssertEqual(pointA.angle(to: pointB), Float.pi * 0.5, accuracy: epsilon)
    }

    func testPointToBack() {
        let pointA = GridPoint(x: -50, z: 45)
        let pointB = GridPoint(x: -50, z: 40)

        XCTAssertEqual(pointA.angle(to: pointB), 0.0, accuracy: epsilon)
    }
}
