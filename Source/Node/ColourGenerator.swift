import UIKit

class ColourGenerator {
    private let gen: ValueGenerator
    private let minimumHueDifference: CGFloat = 0.5
    private let hueRange = 0 ..< 255
    private let floorSaturationRange = 230 ..< 255
    private let slopeSaturationRange = 100 ..< 128

    private var lastHue: CGFloat = 0.0

    init(level: Int) {
        gen = CosineValueGenerator(input: level)
    }

    func nextHue() -> CGFloat {
        var hue: CGFloat
        repeat {
            hue = nextValue(range: hueRange)
        } while abs(hue - lastHue) <= minimumHueDifference

        lastHue = hue
        return hue
    }

    func nextFloorSaturation() -> CGFloat {
        return nextValue(range: floorSaturationRange)
    }

    func nextSlopeSaturation() -> CGFloat {
        return nextValue(range: slopeSaturationRange)
    }

    private func nextValue(range: CountableRange<Int>) -> CGFloat {
        let next = gen.next(range: range)
        return CGFloat(next) / 255.0
    }
}
