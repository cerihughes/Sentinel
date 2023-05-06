import XCTest

@testable import Sentinel

class GridBuilderSlopeTests: XCTestCase {
    func test_1x1() {
        let builder = GridBuilder(width: 1, depth: 1)
        let point = GridPoint(x: 0, z: 0)
        builder.buildFloor(at: point)
        builder.processSlopes()

        assertSlope(in: builder, x: 0, z: 0, description: "****:1.0")
    }

    func test_1x1_buildTwice() {
        let builder = GridBuilder(width: 1, depth: 1)
        let point = GridPoint(x: 0, z: 0)
        builder.buildFloor(at: point)
        builder.buildFloor(at: point)
        builder.processSlopes()

        assertSlope(in: builder, x: 0, z: 0, description: "****:2.0")
    }

    func test_2x2() {
        let builder = GridBuilder(width: 2, depth: 2)
        let point = GridPoint(x: 0, z: 0)
        builder.buildFloor(at: point)
        builder.processSlopes()

        assertSlope(in: builder, z: 0, description: "****:1.0 *E**:0.5")
        assertSlope(in: builder, z: 1, description: "**S*:0.5 ****:0.0")
    }

    func test_2x2_buildTwice() {
        let builder = GridBuilder(width: 2, depth: 2)
        let point = GridPoint(x: 0, z: 0)
        builder.buildFloor(at: point)
        builder.buildFloor(at: point)
        builder.processSlopes()

        assertSlope(in: builder, z: 0, description: "****:2.0 *E**:1.5")
        assertSlope(in: builder, z: 1, description: "**S*:1.5 *ES*:0.5")
    }

    func test_2x2_adjacentHorizontalBuilds() {
        let builder = GridBuilder(width: 2, depth: 2)
        let point1 = GridPoint(x: 0, z: 0)
        let point2 = GridPoint(x: 1, z: 0)
        builder.buildFloor(at: point1)
        builder.buildFloor(at: point2)
        builder.processSlopes()

        assertSlope(in: builder, z: 0, description: "****:1.0 ****:1.0")
        assertSlope(in: builder, z: 1, description: "**S*:0.5 **S*:0.5")
    }

    func test_3x3() {
        let builder = GridBuilder(width: 3, depth: 3)
        let point = GridPoint(x: 1, z: 1)
        builder.buildFloor(at: point)
        builder.processSlopes()

        assertSlope(in: builder, z: 0, description: "****:0.0 N***:0.5 ****:0.0")
        assertSlope(in: builder, z: 1, description: "***W:0.5 ****:1.0 *E**:0.5")
        assertSlope(in: builder, z: 2, description: "****:0.0 **S*:0.5 ****:0.0")
    }

    func test_3x3_noBuild() {
        let builder = GridBuilder(width: 3, depth: 3)
        builder.processSlopes()

        assertSlope(in: builder, z: 0, description: "****:0.0 ****:0.0 ****:0.0")
        assertSlope(in: builder, z: 1, description: "****:0.0 ****:0.0 ****:0.0")
        assertSlope(in: builder, z: 2, description: "****:0.0 ****:0.0 ****:0.0")
    }

    func test_3x3_buildTwice() {
        let builder = GridBuilder(width: 3, depth: 3)
        let point = GridPoint(x: 1, z: 1)
        builder.buildFloor(at: point)
        builder.buildFloor(at: point)
        builder.processSlopes()

        assertSlope(in: builder, z: 0, description: "N**W:0.5 N***:1.5 NE**:0.5")
        assertSlope(in: builder, z: 1, description: "***W:1.5 ****:2.0 *E**:1.5")
        assertSlope(in: builder, z: 2, description: "**SW:0.5 **S*:1.5 *ES*:0.5")
    }

    func test_3x1_withSpacer() {
        let builder = GridBuilder(width: 3, depth: 1)
        let point1 = GridPoint(x: 0, z: 0)
        let point2 = GridPoint(x: 2, z: 0)
        builder.buildFloor(at: point1)
        builder.buildFloor(at: point2)
        builder.processSlopes()

        assertSlope(in: builder, z: 0, description: "****:1.0 *E*W:0.5 ****:1.0")
    }

    func test_3x3_withSpacer() {
        let builder = GridBuilder(width: 3, depth: 3)
        let point1 = GridPoint(x: 1, z: 0)
        let point2 = GridPoint(x: 0, z: 1)
        let point3 = GridPoint(x: 2, z: 1)
        let point4 = GridPoint(x: 1, z: 2)
        builder.buildFloor(at: point1)
        builder.buildFloor(at: point2)
        builder.buildFloor(at: point3)
        builder.buildFloor(at: point4)
        builder.processSlopes()

        assertSlope(in: builder, z: 0, description: "N**W:0.5 ****:1.0 NE**:0.5")
        assertSlope(in: builder, z: 1, description: "****:1.0 NESW:0.5 ****:1.0")
        assertSlope(in: builder, z: 2, description: "**SW:0.5 ****:1.0 *ES*:0.5")
    }

    func testLargeGrid() {
        let builder = GridBuilder(width: 7, depth: 7)
        builder.buildFloor(at: GridPoint(x: 3, z: 3))
        builder.buildFloor(at: GridPoint(x: 3, z: 3))
        builder.buildFloor(at: GridPoint(x: 3, z: 3))
        builder.processSlopes()

        assertSlope(in: builder, z: 0, description: "****:0.0 ****:0.0 ****:0.0 N***:0.5 ****:0.0 ****:0.0 ****:0.0")
        assertSlope(in: builder, z: 1, description: "****:0.0 ****:0.0 N**W:0.5 N***:1.5 NE**:0.5 ****:0.0 ****:0.0")
        assertSlope(in: builder, z: 2, description: "****:0.0 N**W:0.5 N**W:1.5 N***:2.5 NE**:1.5 NE**:0.5 ****:0.0")
        assertSlope(in: builder, z: 3, description: "***W:0.5 ***W:1.5 ***W:2.5 ****:3.0 *E**:2.5 *E**:1.5 *E**:0.5")
        assertSlope(in: builder, z: 4, description: "****:0.0 **SW:0.5 **SW:1.5 **S*:2.5 *ES*:1.5 *ES*:0.5 ****:0.0")
        assertSlope(in: builder, z: 5, description: "****:0.0 ****:0.0 **SW:0.5 **S*:1.5 *ES*:0.5 ****:0.0 ****:0.0")
        assertSlope(in: builder, z: 6, description: "****:0.0 ****:0.0 ****:0.0 **S*:0.5 ****:0.0 ****:0.0 ****:0.0")
    }

    private func assertSlope(
        in builder: GridBuilder,
        z: Int,
        description: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let width = builder.width
        let descriptions = description.components(separatedBy: " ")
        XCTAssertEqual(width, descriptions.count, file: file, line: line)
        for (index, value) in descriptions.enumerated() {
            assertSlope(in: builder, x: index, z: z, description: value, file: file, line: line)
        }
    }

    private func assertSlope(
        in builder: GridBuilder,
        x: Int,
        z: Int,
        description: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let point = GridPoint(x: x, z: z)
        guard let piece = builder.piece(at: point) else {
            XCTFail("No piece at \(point.x), \(point.z)")
            return
        }
        let actualDescription = piece.slopesDescription
        XCTAssertEqual(actualDescription, description, file: file, line: line)
    }
}
