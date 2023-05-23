import UIKit

class IntroTerrainGenerator: TerrainGenerator {
    func generate() -> Grid {
        guard let image = UIImage.create(text: "The Sentinel") else { return .fallback }
        let pattern = UIImagePattern(image: image)
        let patternGenerator = PatternGenerator(pattern: pattern)
        return patternGenerator.generate()
    }
}

private extension Grid {
    static let fallback = Grid(
        width: 20,
        depth: 20,
        pieces: [],
        sentinelPosition: .undefined,
        sentryPositions: [],
        startPosition: .undefined,
        treePositions: [],
        synthoidPositions: [],
        currentPosition: .undefined
    )
}
