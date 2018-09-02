import XCTest
@testable import Sentinel

class GridTests: XCTestCase {

    func test_1x1() {
        let grid = Grid(width: 1, depth: 1)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)

        assertPiece(in: grid, at: point, expectedLevel: 1, expectedShapes: [.flat])
    }

    func test_1x1_buildTwice() {
        let grid = Grid(width: 1, depth: 1)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)
        grid.build(at: point)

        assertPiece(in: grid, at: point, expectedLevel: 2, expectedShapes: [.flat])
    }

    func test_2x2() {
        let grid = Grid(width: 2, depth: 2)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)
        outputLevels(grid: grid)
        outputShapes(grid: grid)

        assertPiece(in: grid, at: point, expectedLevel: 1, expectedShapes: [.flat])
        assertPiece(in: grid, at: GridPoint(x: 1, z: 0), expectedLevel: 1, expectedShapes: [.slopeDownX])
        assertPiece(in: grid, at: GridPoint(x: 0, z: 1), expectedLevel: 1, expectedShapes: [.slopeDownZ])
        assertPiece(in: grid, at: GridPoint(x: 1, z: 1), expectedLevel: 0, expectedShapes: [.flat])
    }

    func test_2x2_buildTwice() {
        let grid = Grid(width: 2, depth: 2)
        let point = GridPoint(x: 0, z: 0)
        grid.build(at: point)
        grid.build(at: point)
        outputLevels(grid: grid)
        outputShapes(grid: grid)

        assertPiece(in: grid, at: point, expectedLevel: 2, expectedShapes: [.flat])
        assertPiece(in: grid, at: GridPoint(x: 1, z: 0), expectedLevel: 2, expectedShapes: [.slopeDownX])
        assertPiece(in: grid, at: GridPoint(x: 0, z: 1), expectedLevel: 2, expectedShapes: [.slopeDownZ])
        assertPiece(in: grid, at: GridPoint(x: 1, z: 1), expectedLevel: 1, expectedShapes: [.slopeDownX, .slopeDownZ])
    }

    func test_2x2_adjacentHorizontalBuilds() {
        let grid = Grid(width: 2, depth: 2)
        let point1 = GridPoint(x: 0, z: 0)
        let point2 = GridPoint(x: 1, z: 0)
        grid.build(at: point1)
        outputLevels(grid: grid)
        outputShapes(grid: grid)
        grid.build(at: point2)
        outputLevels(grid: grid)
        outputShapes(grid: grid)

        assertPiece(in: grid, at: point1, expectedLevel: 1, expectedShapes: [.flat])
        assertPiece(in: grid, at: point2, expectedLevel: 1, expectedShapes: [.flat])
        assertPiece(in: grid, at: GridPoint(x: 0, z: 1), expectedLevel: 1, expectedShapes: [.slopeDownZ])
        assertPiece(in: grid, at: GridPoint(x: 1, z: 1), expectedLevel: 1, expectedShapes: [.slopeDownZ])
    }

    func test_3x3() {
        let grid = Grid(width: 3, depth: 3)
        let point = GridPoint(x: 1, z: 1)
        grid.build(at: point)

        assertPiece(in: grid, at: GridPoint(x: 0, z: 0), expectedLevel: 0, expectedShapes: [.flat])
        assertPiece(in: grid, at: GridPoint(x: 1, z: 0), expectedLevel: 1, expectedShapes: [.slopeUpZ])
        assertPiece(in: grid, at: GridPoint(x: 2, z: 0), expectedLevel: 0, expectedShapes: [.flat])
        assertPiece(in: grid, at: GridPoint(x: 0, z: 1), expectedLevel: 1, expectedShapes: [.slopeUpX])
        assertPiece(in: grid, at: point, expectedLevel: 1, expectedShapes: [.flat])
        assertPiece(in: grid, at: GridPoint(x: 2, z: 1), expectedLevel: 1, expectedShapes: [.slopeDownX])
        assertPiece(in: grid, at: GridPoint(x: 0, z: 2), expectedLevel: 0, expectedShapes: [.flat])
        assertPiece(in: grid, at: GridPoint(x: 1, z: 2), expectedLevel: 1, expectedShapes: [.slopeDownZ])
        assertPiece(in: grid, at: GridPoint(x: 2, z: 2), expectedLevel: 0, expectedShapes: [.flat])
    }

    func test_3x3_buildTwice() {
        let grid = Grid(width: 3, depth: 3)
        let point = GridPoint(x: 1, z: 1)
        grid.build(at: point)
        outputLevels(grid: grid)
        grid.build(at: point)
        outputLevels(grid: grid)

        assertPiece(in: grid, at: GridPoint(x: 0, z: 0), expectedLevel: 1, expectedShapes: [.slopeUpX, .slopeUpZ])
        assertPiece(in: grid, at: GridPoint(x: 1, z: 0), expectedLevel: 2, expectedShapes: [.slopeUpZ])
        assertPiece(in: grid, at: GridPoint(x: 2, z: 0), expectedLevel: 1, expectedShapes: [.slopeDownX, .slopeUpZ])
        assertPiece(in: grid, at: GridPoint(x: 0, z: 1), expectedLevel: 2, expectedShapes: [.slopeUpX])
        assertPiece(in: grid, at: point, expectedLevel: 2, expectedShapes: [.flat])
        assertPiece(in: grid, at: GridPoint(x: 2, z: 1), expectedLevel: 2, expectedShapes: [.slopeDownX])
        assertPiece(in: grid, at: GridPoint(x: 0, z: 2), expectedLevel: 1, expectedShapes: [.slopeDownX, .slopeUpZ])
        assertPiece(in: grid, at: GridPoint(x: 1, z: 2), expectedLevel: 2, expectedShapes: [.slopeDownZ])
        assertPiece(in: grid, at: GridPoint(x: 2, z: 2), expectedLevel: 1, expectedShapes: [.slopeDownX, .slopeDownZ])
    }

    func test_3x1_withSpacer() {
        let grid = Grid(width: 3, depth: 1)
        let point1 = GridPoint(x: 0, z: 0)
        let point2 = GridPoint(x: 2, z: 0)
        grid.build(at: point1)
        grid.build(at: point2)
        outputLevels(grid: grid)
        outputShapes(grid: grid)

        assertPiece(in: grid, at: point1, expectedLevel: 1, expectedShapes: [.flat])
        assertPiece(in: grid, at: GridPoint(x: 1, z: 0), expectedLevel: 1, expectedShapes: [.slopeDownX, .slopeUpX])
        assertPiece(in: grid, at: point2, expectedLevel: 1, expectedShapes: [.flat])
    }

    private func assertPiece(in grid: Grid,
                             at point: GridPoint,
                             expectedLevel: Int,
                             expectedShapes: [GridShape],
                             file: StaticString = #file,
                             line: UInt = #line) {
        let piece = grid.get(point: point)
        XCTAssertEqual(piece.level, expectedLevel, file: file, line: line)
        let sortFunction: (GridShape, GridShape) -> Bool = {shape1, shape2 in
            return self.value(for: shape1) < self.value(for: shape2)
        }
        XCTAssertEqual(piece.shapes.sorted(by: sortFunction), expectedShapes.sorted(by: sortFunction), file: file, line: line)
    }

    private func value(for shape: GridShape) -> Int {
        switch shape {
        case .flat:
            return 0
        case .slopeDownX:
            return 1
        case .slopeUpX:
            return 2
        case .slopeUpZ:
            return 3
        case .slopeDownZ:
            return 4
        }
    }

    private func outputLevels(grid: Grid) {
        for z in 0 ..< grid.depth {
            for x in 0 ..< grid.width {
                print(grid.get(point: GridPoint(x: x, z: z)).level, terminator: " ")
            }
            print("\n")
        }
    }

    private func outputShapes(grid: Grid) {
        for z in 0 ..< grid.depth {
            for x in 0 ..< grid.width {
                let piece = grid.get(point: GridPoint(x: x, z: z))
                for shape in piece.shapes {
                    print(string(for: shape), terminator: "")
                }
                print(" ", terminator: "")
            }
            print("\n")
        }
    }

    private func string(for shape: GridShape) -> String {
        switch shape {
        case .flat:
            return "__"
        case .slopeDownX:
            return "-x"
        case .slopeUpX:
            return "+x"
        case .slopeDownZ:
            return "-z"
        case .slopeUpZ:
            return "+z"
        }
    }

}
