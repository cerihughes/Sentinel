import SceneKit
import UIKit

class SceneImageLoader: NSObject {
    private let operationQueue = OperationQueue()

    override init() {
        operationQueue.maxConcurrentOperationCount = 2

        super.init()
    }
    
    func loadImage(level: Int, size: CGSize, completion: @escaping (UIImage?) -> Void) {
        let operation = SceneImageLoaderOperation(level: level, size: size, completion: completion)
        operationQueue.addOperation(operation)
    }

    private func createScene(for level: Int) -> SCNScene {
        let levelConfiguration = MainLevelConfiguration(level: level)
        let nodePositioning = NodePositioning(gridWidth: levelConfiguration.gridWidth,
                                              gridDepth: levelConfiguration.gridDepth,
                                              floorSize: floorSize)
        let nodeFactory = NodeFactory(nodePositioning: nodePositioning,
                                      detectionRadius: levelConfiguration.opponentDetectionRadius * floorSize)

        let world = SpaceWorld(nodeFactory: nodeFactory)
        return world.scene
    }

    private class SceneImageLoaderOperation: Operation {
        let level: Int
        let view: SCNView
        let completion: (UIImage?) -> Void

        init(level: Int, size: CGSize, completion: @escaping (UIImage?) -> Void) {
            self.level = level
            self.completion = completion
            self.view = SCNView(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size))

            super.init()
        }

        // MARK: Operation

        private var _executing = false {
            willSet {
                willChangeValue(forKey: "isExecuting")
            }
            didSet {
                didChangeValue(forKey: "isExecuting")
            }
        }

        override var isExecuting: Bool {
            return _executing
        }

        private var _finished = false {
            willSet {
                willChangeValue(forKey: "isFinished")
            }

            didSet {
                didChangeValue(forKey: "isFinished")
            }
        }

        override var isFinished: Bool {
            return _finished
        }

        override func start() {
            _executing = true

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

            _executing = false
            _finished = true
        }
    }
}
