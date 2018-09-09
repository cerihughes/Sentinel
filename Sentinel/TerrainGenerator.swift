import UIKit

class TerrainGenerator: NSObject {
    var grid: Grid!

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
        
        grid.sentinelPosition = generateSentinel(gen: gen, difficultyAdjustment: difficultyAdjustment)
        grid.sentryPositions = generateSentries(gen: gen, difficultyAdjustment: difficultyAdjustment)
        grid.startPosition = generateStartPosition(gen: gen)
        grid.treePositions = generateTrees(gen: gen, difficultyAdjustment: difficultyAdjustment)

        normalise()
        
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

    private func generateTrees(gen: ValueGenerator, difficultyAdjustment: Int) -> [GridPoint] {
        let minCount = (16 - (difficultyAdjustment * 2)) / 4
        let maxCount = (24 - (difficultyAdjustment * 2)) / 4

        var trees: [GridPoint] = []
        for quadrant in GridQuadrant.allValues() {
            let treesInQuadrant = generateTrees(minCount: minCount,
                                                maxCount: maxCount,
                                                quadrant: quadrant,
                                                gen: gen)
            trees.append(contentsOf: treesInQuadrant)
        }

        return trees
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
        let pieces = gridIndex.highestFloorPieces()
        if pieces.count == 1 {
            return pieces[0]
        }

        let index = gen.next(min: 0, max: pieces.count - 1)
        return pieces[index]
    }

    private func generateSentries(gen: ValueGenerator, difficultyAdjustment: Int) -> [GridPoint] {
        guard 1 ... 3 ~= difficultyAdjustment else {
            return []
        }

        var sentryPieces: [GridPiece] = []
        for quadrant in GridQuadrant.allValues() {
            if !quadrant.contains(point: grid.sentinelPosition, grid: grid) {
                let gridIndex = GridIndex(grid: grid, quadrant: quadrant)
                sentryPieces.append(highestPiece(in: gridIndex, gen: gen))
            }
        }

        // Sort by level
        sentryPieces = sentryPieces.sorted { return $0.level < $1.level }

        let points = sentryPieces.map { return $0.point }
        return Array(points.prefix(difficultyAdjustment))
    }

    private func generateStartPosition(gen: ValueGenerator) -> GridPoint {
        let gridIndex: GridIndex
        if let opposite = quadrantOppositeSentinel() {
            gridIndex = GridIndex(grid: grid, quadrant: opposite)
        } else {
            // Fallback, although this should never happen unless my maths is off :O
            gridIndex = GridIndex(grid: grid)
        }

        let startPieces = gridIndex.lowestFloorPieces()
        if startPieces.count == 1 {
            return startPieces[0].point
        }

        let index = gen.next(min: 0, max: startPieces.count - 1)
        let point = startPieces[index].point
        grid.synthoidPositions.append(point)
        
        return point
    }

    private func quadrantOppositeSentinel() -> GridQuadrant? {
        for quadrant in GridQuadrant.allValues() {
            if quadrant.contains(point: grid.sentinelPosition, grid: grid) {
                return quadrant.opposite
            }
        }
        return nil
    }

    private func normalise() {
        let gridIndex = GridIndex(grid: grid)
        if let lowestLevel = gridIndex.floorLevels().first, lowestLevel > 0 {
            for z in 0 ..< grid.depth {
                for x in 0 ..< grid.width {
                    if let piece = grid.get(point: GridPoint(x: x, z: z)) {
                        piece.level -= Float(lowestLevel)
                    }
                }
            }
        }
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

    private func generateTrees(minCount: Int,
                               maxCount: Int,
                               quadrant: GridQuadrant,
                               gen: ValueGenerator) -> [GridPoint] {
        let gridIndex = GridIndex(grid: grid, quadrant: quadrant)
        var allPieces = gridIndex.allPieces()
        var treePoints: [GridPoint] = []

        var count = gen.next(min: minCount, max: maxCount)
        if (count > allPieces.count) {
            count = allPieces.count
        }

        for _ in 0 ..< count {
            let index = gen.next(min: 0, max: allPieces.count - 1)
            let piece = allPieces.remove(at: index)
            treePoints.append(piece.point)
        }

        return treePoints
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
