import Foundation

/**
 Produces pseudo-random values for a given input. Output shouldn't be predictable, but be repeatable for the same input.
 */
protocol ValueGenerator {
    /// Returns a pseudo-rndom number between value1 and value2 _inclusive_ (i.e. it could return value1 or value2).
    func nextValue(between value1: Int, and value2: Int) -> Int
}

extension ValueGenerator {
    func nextValue(in range: CountableRange<Int>) -> Int {
        nextValue(between: range.lowerBound, and: range.upperBound)
    }

    func nextIndex(array: [Any]) -> Int? {
        guard !array.isEmpty else { return nil }
        return nextValue(between: 0, and: array.count - 1)
    }

    func nextItem<T>(array: [T]) -> T? {
        guard let index = nextIndex(array: array) else { return nil }
        if array.indices.contains(index) {
            return array[index]
        } else {
            return nil
        }
    }
}

class CosineValueGenerator: ValueGenerator {
    private var seeds: [Int] = []
    private var genCount = 0

    convenience init(input: Int) {
        let cosine = cos(Float(input) / Float(1 + input))
        let factor = (input + 1) * (input + 2) * (input + 3)
        let seedFloat = Float(factor * factor) / cosine
        let seed = Int(seedFloat)

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

        let m1 = (d1 % 1001) + 1002
        let m2 = (d2 % 1002) + 1003
        let m3 = (d3 % 1003) + 1004
        let m4 = (d4 % 1004) + 1005
        let m5 = (d5 % 1005) + 1006

        self.init(seeds: [m1, m2, m3, m4, m5])
    }

    private init(seeds: [Int]) {
        for _ in 0 ..< 3 {
            self.seeds.append(contentsOf: seeds)
        }
    }

    func nextValue(between value1: Int, and value2: Int) -> Int {
        let min = min(value1, value2)
        let max = max(value1, value2)
        genCount += 1

        var seed = seeds.remove(at: 0)
        seed += genCount

        let value = max - min + 1
        let mod = seed % value
        let result = min + mod

        var seed2 = seeds.remove(at: 0)
        seed2 += mod

        seeds.append(seed)
        seeds.append(seed2)

        return result
    }
}
