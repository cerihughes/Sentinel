import Foundation

class TerrainGenerator: NSObject {
    var grid: Grid!

    func generate(levelConfiguration: LevelConfiguration) -> Grid {
        let width = levelConfiguration.gridWidth
        let depth = levelConfiguration.gridDepth

        grid = Grid(width: width, depth: depth)

        let gen = ValueGenerator(input: levelConfiguration.level)
        generateLargePlateaus(gen: gen, levelConfiguration: levelConfiguration)
        generateSmallPlateaus(gen: gen, levelConfiguration: levelConfiguration)
        generateLargePeaks(gen: gen, levelConfiguration: levelConfiguration)
        generateMediumPeaks(gen: gen, levelConfiguration: levelConfiguration)
        generateSmallPeaks(gen: gen, levelConfiguration: levelConfiguration)

        grid.sentinelPosition = generateSentinel(gen: gen, levelConfiguration: levelConfiguration)
        grid.sentryPositions = generateSentries(gen: gen, levelConfiguration: levelConfiguration)
        grid.startPosition = generateStartPosition(gen: gen)
        grid.treePositions = generateTrees(gen: gen, levelConfiguration: levelConfiguration)

        normalise()
        
        grid.processSlopes()

        return grid
    }

    private func generateLargePlateaus(gen: ValueGenerator, levelConfiguration: LevelConfiguration) {
        generatePlateaus(sizeRange: levelConfiguration.largePlateauSizeRange,
                         countRange: levelConfiguration.largePlateauCountRange,
                         gen: gen)
    }

    private func generateSmallPlateaus(gen: ValueGenerator, levelConfiguration: LevelConfiguration) {
        generatePlateaus(sizeRange: levelConfiguration.smallPlateauSizeRange,
                         countRange: levelConfiguration.smallPlateauCountRange,
                         gen: gen)
    }

    private func generateLargePeaks(gen: ValueGenerator, levelConfiguration: LevelConfiguration) {
        generatePeaks(summitSize: 3,
                      countRange: levelConfiguration.largePeakCountRange,
                      gen: gen)
    }

    private func generateMediumPeaks(gen: ValueGenerator, levelConfiguration: LevelConfiguration) {
        generatePeaks(summitSize: 2,
                      countRange: levelConfiguration.mediumPeakCountRange,
                      gen: gen)
    }

    private func generateSmallPeaks(gen: ValueGenerator, levelConfiguration: LevelConfiguration) {
        generatePeaks(summitSize: 1,
                      countRange: levelConfiguration.smallPeakCountRange,
                      gen: gen)
    }

    private func generateTrees(gen: ValueGenerator, levelConfiguration: LevelConfiguration) -> Set<GridPoint> {
        var trees: Set<GridPoint> = []
        let countRange = levelConfiguration.treeCountRange
        for quadrant in GridQuadrant.allCases {
            let treesInQuadrant = generateTrees(countRange: countRange,
                                                quadrant: quadrant,
                                                gen: gen)
            trees = trees.union(treesInQuadrant)
        }

        return trees
    }

    private func generateSentinel(gen: ValueGenerator, levelConfiguration: LevelConfiguration) -> GridPoint {
        let gridIndex = GridIndex(grid: grid)
        let sentinelPosition = highestPiece(in: gridIndex, gen: gen).point
        for _ in 0 ..< levelConfiguration.sentinelPlatformHeight {
            grid.build(at: sentinelPosition)
        }
        return sentinelPosition
    }

    private func highestPiece(in gridIndex: GridIndex, gen: ValueGenerator) -> GridPiece {
        let pieces = gridIndex.highestFloorPieces()
        if pieces.count == 1 {
            return pieces[0]
        }

        let index = gen.next(array: pieces)
        return pieces[index]
    }

    private func generateSentries(gen: ValueGenerator, levelConfiguration: LevelConfiguration) -> Set<GridPoint> {
        let sentries = levelConfiguration.sentryCount
        guard 1 ... 3 ~= sentries else {
            return []
        }

        var sentryPieces: [GridPiece] = []
        for quadrant in GridQuadrant.allCases {
            if !quadrant.contains(point: grid.sentinelPosition, grid: grid) {
                let gridIndex = GridIndex(grid: grid, quadrant: quadrant)
                sentryPieces.append(highestPiece(in: gridIndex, gen: gen))
            }
        }

        // Sort by level
        sentryPieces = sentryPieces.sorted { return $0.level < $1.level }

        let points = sentryPieces.map { return $0.point }
        return Set(points.prefix(sentries))
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

        let index = gen.next(range: 0 ..< startPieces.count - 1)
        let point = startPieces[index].point
        grid.synthoidPositions.insert(point)
        
        return point
    }

    private func quadrantOppositeSentinel() -> GridQuadrant? {
        for quadrant in GridQuadrant.allCases {
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

    private func generatePlateaus(sizeRange: CountableRange<Int>,
                                  countRange: CountableRange<Int>,
                                  gen: ValueGenerator) {
        let count = gen.next(range: countRange)
        for _ in 0 ..< count {
            let size = gen.next(range: sizeRange)
            let x = gen.next(range: 0 ..< grid.width - 1)
            let z = gen.next(range: 0 ..< grid.depth - 1)
            generatePlateau(x: x, z: z, size: size)
        }
    }

    private func generatePeaks(summitSize: Int,
                               countRange: CountableRange<Int>,
                               gen: ValueGenerator) {
        let count = gen.next(range: countRange)
        for _ in 0 ..< count {
            let x = gen.next(range: 0 ..< grid.width - 1)
            let z = gen.next(range: 0 ..< grid.depth - 1)
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

    private func generateTrees(countRange: CountableRange<Int>,
                               quadrant: GridQuadrant,
                               gen: ValueGenerator) -> Set<GridPoint> {
        let gridIndex = GridIndex(grid: grid, quadrant: quadrant)
        var allPieces = gridIndex.allPieces()
        var treePoints: Set<GridPoint> = []

        var count = gen.next(range: countRange) / 4
        if (count > allPieces.count) {
            count = allPieces.count
        }

        for _ in 0 ..< count {
            let index = gen.next(array: allPieces)
            let piece = allPieces.remove(at: index)
            treePoints.insert(piece.point)
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
