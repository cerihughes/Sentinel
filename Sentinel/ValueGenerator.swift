import Foundation

class ValueGenerator: NSObject {
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

    init(seeds: [Int]) {
        for _ in 0 ..< 3 {
            self.seeds.append(contentsOf: seeds)
        }

        super.init()
    }

    func next(range: CountableRange<Int>) -> Int {
        return next(min: range.lowerBound, max: range.upperBound)
    }

    func next(array: Array<Any>) -> Int {
        return next(min: 0, max: array.count - 1)
    }

    private func next(min: Int, max: Int) -> Int {
        genCount += 1

        var seed = seeds.remove(at: 0)
        seed += genCount

        let value = max - min + 1
        let mod = seed % value
        let result = min + mod

        var seed2 = seeds.remove(at: 0)
        seed2 = seed2 + mod

        seeds.append(seed)
        seeds.append(seed2)

        return result
    }
}
