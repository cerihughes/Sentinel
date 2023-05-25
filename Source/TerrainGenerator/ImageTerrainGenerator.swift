import UIKit

class ImageTerrainGenerator: TerrainGenerator {
    private let image: UIImage

    init(image: UIImage) {
        self.image = image
    }

    func generate() -> Grid {
        let pattern = UIImagePattern(image: image)
        let patternGenerator = PatternGenerator(pattern: pattern)
        return patternGenerator.generate()
    }
}
