import UIKit

class TerrainGenerator: NSObject {
    let grid: Grid

    init(width: Int, depth: Int) {
        grid = Grid(width: width, depth: depth)

        super.init()
    }

    func generate(level: Int) -> Grid {
        let inc = (level + 1) * (level + 1)
        let seed = inc * 67

        let s1 = seed << 1
        let s2 = seed << 2
        let s3 = seed << 3
        let s4 = seed << 4
        let s5 = seed << 5

        let d1 = s1 + (s2 / s3) + (s4 / s5)
        let d2 = s2 + (s3 / s4) + (s5 / s1)
        let d3 = s3 + (s4 / s5) + (s1 / s2)
        let d4 = s4 + (s5 / s1) + (s2 / s3)
        let d5 = s5 + (s1 / s2) + (s3 / s4)

        let gen1 = ValueGenerator(seed1: d1, seed2: d2)
        let gen2 = ValueGenerator(seed1: d2, seed2: d3)
        let gen3 = ValueGenerator(seed1: d3, seed2: d4)
        let gen4 = ValueGenerator(seed1: d4, seed2: d5)
        let gen5 = ValueGenerator(seed1: d5, seed2: d1)

        generateLargePlateaus(gen: gen1)
        generateSmallPlateaus(gen: gen2)
        generateLargePeaks(gen: gen3)
        generateMediumPeaks(gen: gen4)
        generateSmallPeaks(gen: gen5)

        return grid
    }
}

extension TerrainGenerator {
    private func generateLargePlateaus(gen: ValueGenerator) {
        generatePlateaus(minSize: 7,
                         maxSize: 11,
                         minCount: 3,
                         maxCount: 6,
                         gen: gen)
    }

    private func generateSmallPlateaus(gen: ValueGenerator) {
        generatePlateaus(minSize: 4,
                         maxSize: 6,
                         minCount: 3,
                         maxCount: 7,
                         gen: gen)
    }

    private func generateLargePeaks(gen: ValueGenerator) {
        generatePeaks(summitSize: 3,
                      minCount: 1,
                      maxCount: 5,
                      gen: gen)
    }

    private func generateMediumPeaks(gen: ValueGenerator) {
        generatePeaks(summitSize: 2,
                      minCount: 2,
                      maxCount: 6,
                      gen: gen)
    }

    private func generateSmallPeaks(gen: ValueGenerator) {
        generatePeaks(summitSize: 1,
                      minCount: 10,
                      maxCount: 20,
                      gen: gen)
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

class ValueGenerator: NSObject {
    var seed1: Int
    var seed2: Int
    var genCount = 0

    init(seed1: Int, seed2: Int) {
        self.seed1 = seed1
        self.seed2 = seed2

        super.init()
    }

    func next(min: Int, max: Int) -> Int {
        genCount += 1

        let value = max - min + 1
        let mod = seed() % value
        let result = min + mod

        seed1 = seed1 - (result - genCount)
        seed2 = seed2 - (result - genCount)

        return result
    }

    private func seed() -> Int {
        return genCount % 2 == 0 ? seed1 : seed2
    }

}
