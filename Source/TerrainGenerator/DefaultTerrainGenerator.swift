import Foundation

class DefaultTerrainGenerator: TerrainGenerator {
    private let levelConfiguration: LevelConfiguration
    private let grid: Grid
    private let gen: ValueGenerator

    init(levelConfiguration: LevelConfiguration) {
        self.levelConfiguration = levelConfiguration
        grid = Grid(width: levelConfiguration.gridWidth, depth: levelConfiguration.gridDepth)
        gen = CosineValueGenerator(input: levelConfiguration.level)
    }

    func generate() -> Grid {
        generateLargePlateaus()
        generateSmallPlateaus()
        generateLargePeaks()
        generateMediumPeaks()
        generateSmallPeaks()

        grid.sentinelPosition = generateSentinel()
        grid.sentryPositions = generateSentries()
        grid.startPosition = generateStartPosition()
        grid.treePositions = generateTrees()

        normalise()

        grid.processSlopes()

        return grid
    }

    private func generateLargePlateaus() {
        generatePlateaus(
            sizeRange: levelConfiguration.largePlateauSizeRange,
            countRange: levelConfiguration.largePlateauCountRange
        )
    }

    private func generateSmallPlateaus() {
        generatePlateaus(
            sizeRange: levelConfiguration.smallPlateauSizeRange,
            countRange: levelConfiguration.smallPlateauCountRange
        )
    }

    private func generateLargePeaks() {
        generatePeaks(summitSize: 3, countRange: levelConfiguration.largePeakCountRange)
    }

    private func generateMediumPeaks() {
        generatePeaks(summitSize: 2, countRange: levelConfiguration.mediumPeakCountRange)
    }

    private func generateSmallPeaks() {
        generatePeaks(summitSize: 1, countRange: levelConfiguration.smallPeakCountRange)
    }

    private func generateTrees() -> Set<GridPoint> {
        var trees: Set<GridPoint> = []
        let countRange = levelConfiguration.treeCountRange
        for quadrant in GridQuadrant.allCases {
            let treesInQuadrant = generateTrees(countRange: countRange, quadrant: quadrant)
            trees = trees.union(treesInQuadrant)
        }

        return trees
    }

    private func generateSentinel() -> GridPoint {
        guard let highestPiece = highestPiece(in: grid.emptyFloorPiecesByLevel()) else { return .undefined }
        let sentinelPosition = highestPiece.point
        for _ in 0 ..< levelConfiguration.sentinelPlatformHeight {
            grid.build(at: sentinelPosition)
        }
        return sentinelPosition
    }

    private func highestPiece(in floorIndex: [Int: [GridPiece]]) -> GridPiece? {
        let pieces = floorIndex.highestEmptyFloorPieces()
        return gen.nextItem(array: pieces)
    }

    private func generateSentries() -> Set<GridPoint> {
        let sentries = levelConfiguration.sentryCount
        guard 1 ... 3 ~= sentries else {
            return []
        }

        let points = GridQuadrant.allCases
            .filter { !$0.contains(point: grid.sentinelPosition, grid: grid) }
            .compactMap { highestPiece(in: grid.emptyFloorPiecesByLevel(in: $0)) }
            .sorted { $0.level < $1.level }
            .map { $0.point }

        return Set(points.prefix(sentries))
    }

    private func generateStartPosition() -> GridPoint {
        let floorIndex = grid.emptyFloorPiecesByLevel(in: quadrantOppositeSentinel())
        let startPieces = floorIndex.lowestEmptyFloorPieces()
        let point = gen.nextItem(array: startPieces)?.point ?? .undefined
        grid.synthoidPositions.insert(point)
        return point
    }

    private func quadrantOppositeSentinel() -> GridQuadrant {
        quadrantContainingSentinel().opposite
    }

    private func quadrantContainingSentinel() -> GridQuadrant {
        GridQuadrant.allCases.first { $0.contains(point: grid.sentinelPosition, grid: grid) } ?? .northEast
    }

    private func normalise() {
        if let lowestLevel = grid.emptyFloorPiecesByLevel().floorLevels().first, lowestLevel > 0 {
            for z in 0 ..< grid.depth {
                for x in 0 ..< grid.width {
                    if let piece = grid.piece(at: GridPoint(x: x, z: z)) {
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
            let x = gen.nextValue(in: 0 ..< grid.width - 1)
            let z = gen.nextValue(in: 0 ..< grid.depth - 1)
            generatePlateau(x: x, z: z, size: size)
        }
    }

    private func generatePeaks(summitSize: Int, countRange: CountableRange<Int>) {
        let count = gen.nextValue(in: countRange)
        for _ in 0 ..< count {
            let x = gen.nextValue(in: 0 ..< grid.width - 1)
            let z = gen.nextValue(in: 0 ..< grid.depth - 1)
            generatePeak(x: x, z: z, summitSize: summitSize)
        }
    }

    private func generatePlateau(x: Int, z: Int, size: Int) {
        let maxX = max(x: x, size: size)
        let maxZ = max(z: z, size: size)

        for i in x ... maxX {
            for j in z ... maxZ {
                grid.build(at: GridPoint(x: i, z: j))
            }
        }
    }

    private func generateTrees(countRange: CountableRange<Int>, quadrant: GridQuadrant) -> Set<GridPoint> {
        var allPieces = grid.emptyFloorPiecesByLevel(in: quadrant).allEmptyFloorPieces()
        var treePoints: Set<GridPoint> = []

        var count = gen.nextValue(in: countRange) / 4
        if count > allPieces.count {
            count = allPieces.count
        }

        for _ in 0 ..< count {
            guard let index = gen.nextIndex(array: allPieces) else { continue }
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
                grid.build(at: GridPoint(x: i, z: j))
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

extension Grid {
    func build(at point: GridPoint) {
        buildFloor(point: point)
    }

    func processSlopes() {
        for z in 0 ..< depth {
            var startPoint = GridPoint(x: 0, z: z)
            processSlopes(from: startPoint, direction: .east)

            startPoint = GridPoint(x: width - 1, z: z)
            processSlopes(from: startPoint, direction: .west)
        }

        for x in 0 ..< width {
            var startPoint = GridPoint(x: x, z: 0)
            processSlopes(from: startPoint, direction: .south)

            startPoint = GridPoint(x: x, z: depth - 1)
            processSlopes(from: startPoint, direction: .north)
        }
    }

    private func buildFloor(point: GridPoint) {
        guard let piece = piece(at: point) else { return }

        let slopeLevel = piece.buildFloor() - 0.5
        for direction in GridDirection.allCases {
            buildSlope(from: point, level: slopeLevel, direction: direction)
        }
    }

    private func buildSlope(from point: GridPoint, level: Float, direction: GridDirection) {
        let nextPoint = neighbour(of: point, direction: direction)
        if let nextPiece = piece(at: nextPoint) {
            let nextLevel = nextPiece.level

            if level <= nextLevel {
                return
            }

            if level - nextLevel == 1.0 {
                buildFloor(point: nextPoint)
            }

            let nextSlopeLevel = nextPiece.buildSlope() - 1.0

            for direction in GridDirection.allCases(except: direction.opposite) {
                buildSlope(from: nextPoint, level: nextSlopeLevel, direction: direction)
            }
        }
    }

    private func processSlopes(from point: GridPoint, direction: GridDirection) {
        guard let firstPiece = piece(at: point) else { return }

        var slopeLevel = firstPiece.isFloor ? firstPiece.level - 0.5 : firstPiece.level - 1.0
        var nextPoint = neighbour(of: point, direction: direction)
        var nextPiece = piece(at: nextPoint)
        while nextPiece != nil {
            let nextExists = nextPiece!
            if nextExists.isFloor {
                slopeLevel = nextExists.level - 0.5
            } else {
                if nextExists.level == slopeLevel {
                    nextExists.add(slopeDirection: direction)
                    slopeLevel -= 1.0
                } else {
                    slopeLevel = nextExists.level - 1.0
                }
            }

            nextPoint = neighbour(of: nextPoint, direction: direction)
            nextPiece = piece(at: nextPoint)
        }
    }

    private func neighbour(of point: GridPoint, direction: GridDirection) -> GridPoint {
        let deltas = direction.toDelta()
        return point.transform(deltaX: deltas.x, deltaZ: deltas.z)
    }
}

private extension GridPoint {
    func transform(deltaX: Int, deltaZ: Int) -> GridPoint {
        return GridPoint(x: x + deltaX, z: z + deltaZ)
    }
}

private extension GridPiece {
    func buildFloor() -> Float {
        if isFloor {
            level += 1.0
        } else {
            isFloor = true
            level += 0.5
        }
        return level
    }

    func buildSlope() -> Float {
        if isFloor {
            level += 0.5
            isFloor = false
        } else {
            level += 1.0
        }
        return level
    }

    func add(slopeDirection: GridDirection) {
        slopes |= slopeDirection.rawValue
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

    func toDelta() -> (x: Int, z: Int) {
        switch self {
        case .north:
            return (x: 0, z: -1)
        case .east:
            return (x: 1, z: 0)
        case .south:
            return (x: 0, z: 1)
        case .west:
            return (x: -1, z: 0)
        }
    }
}
