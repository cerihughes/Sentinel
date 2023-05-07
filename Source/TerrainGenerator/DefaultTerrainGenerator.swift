import Foundation

class DefaultTerrainGenerator: TerrainGenerator {
    private let gridConfiguration: GridConfiguration
    private let builder: GridBuilder
    private let gen: ValueGenerator

    init(gridConfiguration: GridConfiguration) {
        self.gridConfiguration = gridConfiguration
        builder = .init(width: gridConfiguration.gridWidth, depth: gridConfiguration.gridDepth)
        gen = CosineValueGenerator(input: gridConfiguration.level)
    }

    func generate() -> Grid {
        generateLargePlateaus()
        generateSmallPlateaus()
        generateLargePeaks()
        generateMediumPeaks()
        generateSmallPeaks()

        builder.sentinelPosition = generateSentinel()
        builder.sentryPositions = generateSentries()
        builder.startPosition = generateStartPosition()
        builder.treePositions = generateTrees()

        normalise()

        builder.processSlopes()

        return builder.buildGrid()
    }

    private func generateLargePlateaus() {
        generatePlateaus(
            sizeRange: gridConfiguration.largePlateauSizeRange,
            countRange: gridConfiguration.largePlateauCountRange
        )
    }

    private func generateSmallPlateaus() {
        generatePlateaus(
            sizeRange: gridConfiguration.smallPlateauSizeRange,
            countRange: gridConfiguration.smallPlateauCountRange
        )
    }

    private func generateLargePeaks() {
        generatePeaks(summitSize: 3, countRange: gridConfiguration.largePeakCountRange)
    }

    private func generateMediumPeaks() {
        generatePeaks(summitSize: 2, countRange: gridConfiguration.mediumPeakCountRange)
    }

    private func generateSmallPeaks() {
        generatePeaks(summitSize: 1, countRange: gridConfiguration.smallPeakCountRange)
    }

    private func generateTrees() -> [GridPoint] {
        let countRange = gridConfiguration.treeCountRange
        return GridQuadrant.allCases.flatMap { generateTrees(countRange: countRange, quadrant: $0) }
    }

    private func generateSentinel() -> GridPoint {
        guard let highestPiece = highestPiece(in: builder.emptyFloorPiecesByLevel()) else { return .undefined }
        let sentinelPosition = highestPiece.point
        for _ in 0 ..< gridConfiguration.sentinelPlatformHeight {
            builder.buildFloor(at: sentinelPosition)
        }
        return sentinelPosition
    }

    private func highestPiece(in floorIndex: [Int: [GridPiece]]) -> GridPiece? {
        let pieces = floorIndex.highestEmptyFloorPieces()
        return gen.nextItem(array: pieces)
    }

    private func generateSentries() -> [GridPoint] {
        let sentries = min(gridConfiguration.sentryCount, 3)
        guard sentries > 0, let sentinelPosition = builder.sentinelPosition else { return [] }
        let points = GridQuadrant.allCases
            .filter { !$0.contains(point: sentinelPosition, sizeable: builder) }
            .compactMap { highestPiece(in: builder.emptyFloorPiecesByLevel(in: $0)) }
            .sorted { $0.level < $1.level }
            .map { $0.point }
        return Array(points[0 ..< sentries])
    }

    private func generateStartPosition() -> GridPoint {
        // Player should start on the lowest level as far away from the Sentinel as possible
        let sentinelPoint = builder.sentinelPosition ?? .undefined
        let floorIndex = builder.emptyFloorPiecesByLevel(in: quadrantOppositeSentinel())
        let startPieces = floorIndex.lowestEmptyFloorPieces()
            .sorted { $0.point.distance(from: sentinelPoint) > $1.point.distance(from: sentinelPoint) }
        let point = startPieces.first?.point ?? .undefined
        builder.synthoidPositions.append(point)
        return point
    }

    private func quadrantOppositeSentinel() -> GridQuadrant? {
        quadrantContainingSentinel()?.opposite
    }

    private func quadrantContainingSentinel() -> GridQuadrant? {
        guard let sentinelPosition = builder.sentinelPosition else { return nil }
        return GridQuadrant.allCases.first { $0.contains(point: sentinelPosition, sizeable: builder) }
    }

    private func normalise() {
        if let lowestLevel = builder.emptyFloorPiecesByLevel().floorLevels().first, lowestLevel > 0 {
            for z in 0 ..< builder.depth {
                for x in 0 ..< builder.width {
                    if let piece = builder.piece(at: .init(x: x, z: z)) {
                        piece.level -= Float(lowestLevel)
                    }
                }
            }
        }
    }

    private func generatePlateaus(sizeRange: CountableRange<Int>, countRange: CountableRange<Int>) {
        let count = gen.nextValue(in: countRange)
        for _ in 0 ..< count {
            let size = gen.nextValue(in: sizeRange)
            let x = gen.nextValue(in: 0 ..< builder.width - 1)
            let z = gen.nextValue(in: 0 ..< builder.depth - 1)
            generatePlateau(x: x, z: z, size: size)
        }
    }

    private func generatePeaks(summitSize: Int, countRange: CountableRange<Int>) {
        let count = gen.nextValue(in: countRange)
        for _ in 0 ..< count {
            let x = gen.nextValue(in: 0 ..< builder.width - 1)
            let z = gen.nextValue(in: 0 ..< builder.depth - 1)
            generatePeak(x: x, z: z, summitSize: summitSize)
        }
    }

    private func generatePlateau(x: Int, z: Int, size: Int) {
        let maxX = max(x: x, size: size)
        let maxZ = max(z: z, size: size)

        for i in x ... maxX {
            for j in z ... maxZ {
                builder.buildFloor(at: GridPoint(x: i, z: j))
            }
        }
    }

    private func generateTrees(countRange: CountableRange<Int>, quadrant: GridQuadrant) -> [GridPoint] {
        var allPieces = builder.emptyFloorPiecesByLevel(in: quadrant).allEmptyFloorPieces()
        var treePoints = [GridPoint]()

        let count = min(gen.nextValue(in: countRange) / 4, allPieces.count)

        for _ in 0 ..< count {
            guard let index = gen.nextIndex(array: allPieces) else { continue }
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
                builder.buildFloor(at: GridPoint(x: i, z: j))
            }
        }
    }

    private func max(x: Int, size: Int) -> Int {
        min(builder.width - 1, x + size)
    }

    private func max(z: Int, size: Int) -> Int {
        min(builder.depth - 1, z + size)
    }
}

private extension GridQuadrant {
    var opposite: GridQuadrant {
        switch self {
        case .northWest:
            return .southEast
        case .northEast:
            return .southWest
        case .southWest:
            return .northEast
        case .southEast:
            return .northWest
        }
    }
}

private extension GridDirection {
    var opposite: GridDirection {
        switch self {
        case .north:
            return .south
        case .east:
            return .west
        case .south:
            return .north
        case .west:
            return .east
        }
    }
}

private extension GridPoint {
    func distance(from other: GridPoint) -> Float {
        let xSquared = (x - other.x).squared()
        let zSquared = (z - other.z).squared()
        return sqrtf(.init(xSquared + zSquared))
    }
}

private extension Int {
    func squared() -> Int {
        self * self
    }
}
