import XCTest
@testable import Sentinel

final class ValueGeneratorTests: XCTestCase {

    func testValueInRange() {
        for i in 1..<1000 {
            let gen = CosineValueGenerator(input: i)
            let output = gen.next(range: 0..<i)
            XCTAssertTrue(output >= 0)
            XCTAssertTrue(output <= i)
        }
    }

    func testFixedValueInRange() {
        var output1 = [Int]()
        var output2 = [Int]()
        for i in 1..<1000 {
            let gen = CosineValueGenerator(input: i)
            output1.append(gen.next(range: 51..<51))
            output2.append(51)
        }

        XCTAssertEqual(output1, output2)
    }

    func testValueInArray() throws {
        for i in 1..<1000 {
            let gen = CosineValueGenerator(input: i)
            let array = (0...i).map { _ in i }
            let output = try XCTUnwrap(gen.randomItem(array: array))
            XCTAssertTrue(output >= 0)
            XCTAssertTrue(output <= i)
        }
    }

    func testValueInEmptyArray() {
        let gen = CosineValueGenerator(input: 10)
        let array = [Int]()
        let index = gen.index(array: array)
        let item = gen.randomItem(array: array)
        XCTAssertEqual(index, 0)
        XCTAssertNil(item)
    }

    func testValueInSingleItemArray() {
        let gen = CosineValueGenerator(input: 10)
        let array = ["1"]
        let index = gen.index(array: array)
        let item = gen.randomItem(array: array)
        XCTAssertEqual(index, 0)
        XCTAssertEqual(item, "1")
    }

    func testAscendingInputs() {
        for i in 1..<1000 {
            let gen = CosineValueGenerator(input: i)
            let output = gen.next(value1: 0, value2: i)
            XCTAssertTrue(output >= 0)
            XCTAssertTrue(output <= i)
        }
    }

    func testDescendingInputs() {
        for i in 1..<1000 {
            let gen = CosineValueGenerator(input: i)
            let output = gen.next(value1: i, value2: 0)
            XCTAssertTrue(output >= 0)
            XCTAssertTrue(output <= i)
        }
    }

    func testSameInputsProduceSameOutputs() {
        let gen1 = CosineValueGenerator(input: 0)
        let gen2 = CosineValueGenerator(input: 0)

        var output1 = [Int]()
        var output2 = [Int]()
        for i in 1..<1000 {
            output1.append(gen1.next(value1: 0, value2: i))
            output2.append(gen2.next(value1: 0, value2: i))
        }

        XCTAssertEqual(output1, output2)
    }

    func testDifferentInputsProduceDifferentOutputs() {
        let gen1 = CosineValueGenerator(input: 0)
        let gen2 = CosineValueGenerator(input: 1)

        var output1 = [Int]()
        var output2 = [Int]()
        for i in 1..<1000 {
            output1.append(gen1.next(value1: 0, value2: i))
            output2.append(gen2.next(value1: 0, value2: i))
        }

        XCTAssertNotEqual(output1, output2)
    }
}
