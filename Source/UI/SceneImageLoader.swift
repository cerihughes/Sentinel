import SceneKit
import UIKit

protocol SceneImageLoaderToken {
    func cancel()
}

/**
 Converts a scene into a UIImage for rendering in a Collection View Cell. The image generation is done on a background
 thread to keep things snappy.
 */

typealias SceneImageLoaderCompletion = (UIImage, TimeInterval) -> Void

class SceneImageLoader {
    private let operationQueue = OperationQueue()
    private var cache = NSMutableDictionary()

    init() {
        operationQueue.maxConcurrentOperationCount = 1
    }

    func loadImage(level: Int, size: CGSize, completion: SceneImageLoaderCompletion? = nil) -> SceneImageLoaderToken {
        let operation = SceneImageLoaderOperation(cache: cache, level: level, size: size, completion: completion)
        operationQueue.addOperation(operation)
        if level < 99, cache[level + 1] == nil {
            let nextCacheOperation = SceneImageLoaderOperation(cache: cache, level: level + 1, size: size)
            operationQueue.addOperation(nextCacheOperation)
        }
        if level > 0, cache[level - 1] == nil {
            let previousCacheOperation = SceneImageLoaderOperation(cache: cache, level: level - 1, size: size)
            operationQueue.addOperation(previousCacheOperation)
        }
        return operation
    }

    private class SceneImageLoaderOperation: Operation, SceneImageLoaderToken {
        private let cache: NSMutableDictionary
        let level: Int
        let view: SCNView
        let completion: SceneImageLoaderCompletion?

        init(cache: NSMutableDictionary, level: Int, size: CGSize, completion: SceneImageLoaderCompletion? = nil) {
            self.cache = cache
            self.level = level
            self.completion = completion
            view = SCNView(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size))

            super.init()
        }

        // MARK: Operation

        override func main() {
            let start = DispatchTime.now()

            if let existing = cache[level] as? UIImage {
                invokeCallback(with: existing, start: start)
                return
            }

            let worldBuilder = WorldBuilder.createDefault(level: level)
            let built = worldBuilder.build()
            view.scene = worldBuilder.world.scene
            view.pointOfView = built.initialCameraNode

            let snapshot = view.snapshot()
            cache[level] = snapshot

            invokeCallback(with: snapshot, start: start)
        }

        private func invokeCallback(with image: UIImage, start: DispatchTime) {
            let now = DispatchTime.now()
            let ns = now.uptimeNanoseconds - start.uptimeNanoseconds
            let timeInterval = Double(ns) / 1_000_000_000
            DispatchQueue.main.async {
                self.completion?(image, timeInterval)
            }
        }
    }
}
