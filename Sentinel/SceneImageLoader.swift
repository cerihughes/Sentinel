import SceneKit
import UIKit

protocol SceneImageLoaderToken {
    func cancel()
}

class SceneImageLoader: NSObject {
    private let operationQueue = OperationQueue()
    private var cache: NSMutableDictionary = NSMutableDictionary()

    override init() {
        operationQueue.maxConcurrentOperationCount = 1

        super.init()
    }

    func loadImage(level: Int, size: CGSize, completion: @escaping (UIImage, TimeInterval) -> Void) -> SceneImageLoaderToken {
        let operation = SceneImageLoaderOperation(cache: cache, level: level, size: size, completion: completion)
        operationQueue.addOperation(operation)
        if level < 99 && cache[level + 1] == nil {
            let nextCacheOperation = SceneImageLoaderOperation(cache: cache, level: level + 1, size: size) {_,_ in}
            operationQueue.addOperation(nextCacheOperation)
        }
        if level > 0 && cache[level - 1] == nil {
            let previousCacheOperation = SceneImageLoaderOperation(cache: cache, level: level - 1, size: size) {_,_ in}
            operationQueue.addOperation(previousCacheOperation)
        }
        return operation
    }

    private class SceneImageLoaderOperation: Operation, SceneImageLoaderToken {
        private let cache: NSMutableDictionary
        let level: Int
        let view: SCNView
        let completion: (UIImage, TimeInterval) -> Void

        init(cache: NSMutableDictionary, level: Int, size: CGSize, completion: @escaping (UIImage, TimeInterval) -> Void) {
            self.cache = cache
            self.level = level
            self.completion = completion
            self.view = SCNView(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size))

            super.init()
        }

        // MARK: Operation

        override func main() {
            let start = DispatchTime.now()

            if let existing = cache[level] as? UIImage {
                invokeCallback(with: existing, start: start)
                return
            }

            let levelConfiguration = MainLevelConfiguration(level: level)
            let nodePositioning = NodePositioning(gridWidth: levelConfiguration.gridWidth,
                                                  gridDepth: levelConfiguration.gridDepth,
                                                  floorSize: floorSize)
            let nodeFactory = NodeFactory(nodePositioning: nodePositioning,
                                          detectionRadius: levelConfiguration.opponentDetectionRadius * floorSize)

            let world = SpaceWorld(nodeFactory: nodeFactory)

            let tg = TerrainGenerator()
            let grid = tg.generate(levelConfiguration: levelConfiguration)
            let nodeMap = NodeMap()
            let terrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: nodeMap)
            world.set(terrainNode: terrainNode)

            view.scene = world.scene

            let snapshot = view.snapshot()
            cache[level] = snapshot

            invokeCallback(with: snapshot, start: start)
        }

        private func invokeCallback(with image: UIImage, start: DispatchTime) {
            let now = DispatchTime.now()
            let ns = now.uptimeNanoseconds - start.uptimeNanoseconds
            let timeInterval = Double(ns) / 1_000_000_000
            DispatchQueue.main.async {
                self.completion(image, timeInterval)
            }
        }
    }
}
