import UIKit

class TerrainGenerator: NSObject {
    var grid: Grid!
    var sentinelPosition: GridPoint
    var guardianPositions: [GridPoint] = []
    var playerPosition: GridPoint

    override init() {
        sentinelPosition = GridPoint(x: 0, z: 0)
        playerPosition = GridPoint(x: 0, z: 0)

        super.init()
    }

    func generate(level: Int, maxLevel: Int, minWidth: Int, maxWidth: Int, minDepth: Int, maxDepth: Int) -> Grid {
        let progression = Float(level) / Float(maxLevel)
        let widthAdjustment = progression * Float(maxWidth - minWidth)
        let depthAdjustment = progression * Float(maxDepth - minDepth)
        let width = maxWidth - Int(widthAdjustment)
        let depth = maxDepth - Int(depthAdjustment)

        grid = Grid(width: width, depth: depth)

        let gen = ValueGenerator(input: level)
        generateLargePlateaus(gen: gen)
        generateSmallPlateaus(gen: gen)
        generateLargePeaks(gen: gen)
        generateMediumPeaks(gen: gen)
        generateSmallPeaks(gen: gen)

        var difficultyAdjustment = level / 10
        if difficultyAdjustment > 3 {
            difficultyAdjustment = 3
        }
        sentinelPosition = generateSentinel(gen: gen, difficultyAdjustment: difficultyAdjustment)
        guardianPositions = generateGuardians(gen: gen, sentinelPosition: sentinelPosition, difficultyAdjustment: difficultyAdjustment)
        playerPosition = generatePlayer(gen: gen, sentinelPosition: sentinelPosition)

        grid.processSlopes()

        return grid
    }

    private func generateLargePlateaus(gen: ValueGenerator) {
        generatePlateaus(minSize: 8,
                         maxSize: 12,
                         minCount: 4,
                         maxCount: 7,
                         gen: gen)
    }

    private func generateSmallPlateaus(gen: ValueGenerator) {
        generatePlateaus(minSize: 5,
                         maxSize: 7,
                         minCount: 6,
                         maxCount: 8,
                         gen: gen)
    }

    private func generateLargePeaks(gen: ValueGenerator) {
        generatePeaks(summitSize: 3,
                      minCount: 2,
                      maxCount: 6,
                      gen: gen)
    }

    private func generateMediumPeaks(gen: ValueGenerator) {
        generatePeaks(summitSize: 2,
                      minCount: 3,
                      maxCount: 8,
                      gen: gen)
    }

    private func generateSmallPeaks(gen: ValueGenerator) {
        generatePeaks(summitSize: 1,
                      minCount: 10,
                      maxCount: 30,
                      gen: gen)
    }

    private func generateSentinel(gen: ValueGenerator, difficultyAdjustment: Int) -> GridPoint {
        let gridIndex = GridIndex(grid: grid)
        let sentinelPosition = highestPiece(in: gridIndex, gen: gen).point
        for _ in 0 ..< difficultyAdjustment + 1 {
            grid.build(at: sentinelPosition)
        }
        return sentinelPosition
    }

    private func highestPiece(in gridIndex: GridIndex, gen: ValueGenerator) -> GridPiece {
        let pieces = gridIndex.highestFlatPieces()
        if pieces.count == 1 {
            return pieces[0]
        }

        let index = gen.next(min: 0, max: pieces.count - 1)
        return pieces[index]
    }

    private func generateGuardians(gen: ValueGenerator, sentinelPosition: GridPoint, difficultyAdjustment: Int) -> [GridPoint] {
        guard 1 ... 3 ~= difficultyAdjustment else {
            return []
        }

        var guardianPieces: [GridPiece] = []
        for quadrant in GridQuadrant.allValues() {
            if !quadrant.contains(point: sentinelPosition, grid: grid) {
                let gridIndex = GridIndex(grid: grid, quadrant: quadrant)
                guardianPieces.append(highestPiece(in: gridIndex, gen: gen))
            }
        }

        // Sort by level
        guardianPieces = guardianPieces.sorted { return $0.level < $1.level }

        let points = guardianPieces.map { return $0.point }
        return Array(points.prefix(difficultyAdjustment))
    }

    private func generatePlayer(gen: ValueGenerator, sentinelPosition: GridPoint) -> GridPoint {
        let gridIndex: GridIndex
        if let opposite = quadrantOpposite(point: sentinelPosition) {
            gridIndex = GridIndex(grid: grid, quadrant: opposite)
        } else {
            // Fallback, although this should never happen unless my maths is off :O
            gridIndex = GridIndex(grid: grid)
        }

        let playerPieces = gridIndex.lowestFlatPieces()
        if playerPieces.count == 1 {
            return playerPieces[0].point
        }

        let index = gen.next(min: 0, max: playerPieces.count - 1)
        return playerPieces[index].point
    }

    private func quadrantOpposite(point: GridPoint) -> GridQuadrant? {
        for quadrant in GridQuadrant.allValues() {
            if quadrant.contains(point: sentinelPosition, grid: grid) {
                return quadrant.opposite
            }
        }
        return nil
    }

    private func generatePlateaus(minSize: Int,
                                  maxSize: Int,
                                  minCount: Int,
                                  maxCount: Int,
                                  gen: ValueGenerator) {
        let count = gen.next(min: minCount, max: maxCount)
        for _ in 0 ..< count {
            let size = gen.next(min: minSize, max: maxSize)
            let x = gen.next(min: 0, max: grid.width - 1)
            let z = gen.next(min: 0, max: grid.depth - 1)
            generatePlateau(x: x, z: z, size: size)
        }
    }

    private func generatePeaks(summitSize: Int,
                               minCount: Int,
                               maxCount: Int,
                               gen: ValueGenerator) {
        let count = gen.next(min: minCount, max: maxCount)
        for _ in 0 ..< count {
            let x = gen.next(min: 0, max: grid.width - 1)
            let z = gen.next(min: 0, max: grid.depth - 1)
            generatePeak(x: x, z: z, summitSize: summitSize)
        }
    }

    private func generatePlateau(x: Int, z: Int, size: Int) {
        let maxX = max(x: x, size: size)
        let maxZ = max(z: z, size: size)

        for i in x ... maxX {
            for j in z ... maxZ {
                grid.build(at: GridPoint(x:i, z: j))
            }
        }
    }

    private func generatePeak(x: Int, z: Int, summitSize: Int) {
        let maxX = max(x: x, size: summitSize)
        let maxZ = max(z: z, size: summitSize)

        for i in x ... maxX {
            for j in z ... maxZ {
                grid.build(at: GridPoint(x:i, z: j))
            }
        }
    }

    private func max(x: Int, size: Int) -> Int {
        var maxX = x + size
        if maxX > grid.width - 1 {
            maxX = grid.width - 1
        }
        return maxX
    }

    private func max(z: Int, size: Int) -> Int {
        var maxZ = z + size
        if maxZ > grid.depth - 1 {
            maxZ = grid.depth - 1
        }
        return maxZ
    }
}
