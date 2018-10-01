import SceneKit
import UIKit

protocol SceneImageLoaderToken {
    func cancel()
}

class SceneImageLoader: NSObject {
    private let operationQueue = OperationQueue()

    override init() {
        operationQueue.maxConcurrentOperationCount = 5

        super.init()
    }

    func loadImage(level: Int, size: CGSize, completion: @escaping (UIImage) -> Void) -> SceneImageLoaderToken {
        let operation = SceneImageLoaderOperation(level: level, size: size, completion: completion)
        operationQueue.addOperation(operation)
        return operation
    }

    private class SceneImageLoaderOperation: Operation, SceneImageLoaderToken {
        let level: Int
        let view: SCNView
        let completion: (UIImage) -> Void

        init(level: Int, size: CGSize, completion: @escaping (UIImage) -> Void) {
            self.level = level
            self.completion = completion
            self.view = SCNView(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size))

            super.init()
        }

        // MARK: Operation

        override func main() {
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
            DispatchQueue.main.async {
                self.completion(snapshot)
            }
        }
    }
}
