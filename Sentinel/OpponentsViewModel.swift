import SceneKit

protocol OpponentsViewModelDelegate: class {
    func opponentsViewModel(_: OpponentsViewModel, didDetectOpponent cameraNode: SCNNode)
    func opponentsViewModelDidDepleteEnergy(_: OpponentsViewModel)
    func opponentsViewModel(_: OpponentsViewModel, didEndDetectOpponent cameraNode: SCNNode)
}

class OpponentsViewModel: NSObject, SCNSceneRendererDelegate {
    private let levelConfiguration: LevelConfiguration
    private let terrainViewModel: TerrainViewModel

    private let nodeManipulator: NodeManipulator
    private let grid: Grid

    weak var delegate: OpponentsViewModelDelegate?

    private let timeMachine = TimeMachine()

    init(levelConfiguration: LevelConfiguration, terrainViewModel: TerrainViewModel) {
        self.levelConfiguration = levelConfiguration
        self.terrainViewModel = terrainViewModel

        self.nodeManipulator = terrainViewModel.nodeManipulator
        self.grid = terrainViewModel.grid

        super.init()

        setupTimingFunctions()
    }

    func cameraNode(for viewer: Viewer) -> SCNNode? {
        if let viewingNode = nodeManipulator.viewingNode(for: viewer) {
            return viewingNode.cameraNode
        }
        return nil
    }

    private func oppositionBuildRandomTree() {
        let gridIndex = GridIndex(grid: grid)
        let emptyPieces = gridIndex.allPieces()

        guard emptyPieces.count > 0 else {
            return
        }

        if let randomPiece = emptyPieces.randomElement() {
            terrainViewModel.buildTree(at: randomPiece.point)
        }
    }

    // MARK: SCNSceneRendererDelegate

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        timeMachine.handle(currentTimeInterval: time, renderer: renderer)
    }

    private func setupTimingFunctions() {
        _ = timeMachine.add(timeInterval: 2.0, function: oppositionAbsorbObjects(timeInterval:playerRenderer:lastResult:))
        _ = timeMachine.add(timeInterval: levelConfiguration.opponentRotationPause, function: oppositionRotation(timeInterval:playerRenderer:lastResult:))
        _ = timeMachine.add(timeInterval: 2.0, function: oppositionDetection(timeInterval:playerRenderer:lastResult:))
    }

    private func oppositionAbsorbObjects(timeInterval: TimeInterval, playerRenderer: SCNSceneRenderer, lastResult: Any?) -> Any? {
        guard let synthoidNode = nodeManipulator.currentSynthoidNode else {
            return nil
        }

        for oppositionNode in nodeManipulator.terrainNode.oppositionNodes {
            // Don't absorb the player - this is handled by a separate timing function
            let visibleSynthoids = oppositionNode.visibleSynthoids(in: playerRenderer).filter { $0 != synthoidNode }

            if let visibleSynthoid = visibleSynthoids.randomElement(),
                let floorNode = visibleSynthoid.floorNode,
                let point = nodeManipulator.point(for: floorNode) {
                if terrainViewModel.absorbSynthoidNode(at: point) {
                    terrainViewModel.buildRock(at: point)
                    oppositionBuildRandomTree()
                    return nil
                }
            }

            if let visibleRock = oppositionNode.visibleRocks(in: playerRenderer).randomElement(),
                let floorNode = visibleRock.floorNode,
                let point = nodeManipulator.point(for: floorNode) {
                if terrainViewModel.absorbRockNode(at: point, isFinalRockNode: floorNode.rockNodes.count == 1) {
                    terrainViewModel.buildTree(at: point)
                    oppositionBuildRandomTree()
                    return nil
                }
            }

            if let visibleTree = oppositionNode.visibleTreesOnRocks(in: playerRenderer).randomElement(),
                let floorNode = visibleTree.floorNode,
                let point = nodeManipulator.point(for: floorNode) {
                if terrainViewModel.absorbTreeNode(at: point) {
                    oppositionBuildRandomTree()
                    return nil
                }
            }
        }
        return nil
    }

    private func oppositionRotation(timeInterval: TimeInterval, playerRenderer: SCNSceneRenderer, lastResult: Any?) -> Any? {
        let radians = 2.0 * Float.pi / Float(levelConfiguration.opponentRotationSteps)
        let duration = levelConfiguration.opponentRotationTime
        nodeManipulator.rotateAllOpposition(by: radians, duration: duration)
        return nil
    }

    private func oppositionDetection(timeInterval: TimeInterval, playerRenderer: SCNSceneRenderer, lastResult: Any?) -> Any? {
        guard
            let delegate = delegate,
            let synthoidNode = nodeManipulator.currentSynthoidNode
            else {
                return lastResult
        }

        let oppositionNodes = nodeManipulator.terrainNode.oppositionNodes
        let detectingOppositionNodes = nodes(oppositionNodes, thatSee: synthoidNode, in: playerRenderer)
        let detectingCameraNodes = Set(detectingOppositionNodes.map { $0.cameraNode })
        let lastCameraNodes = lastResult as? Set<SCNNode> ?? []
        if detectingCameraNodes.intersection(lastCameraNodes).count > 0 {
            // Seen by a camera for more than 1 "cycle"...
            delegate.opponentsViewModelDidDepleteEnergy(self)
        }

        for detectingCameraNode in detectingCameraNodes {
            if !lastCameraNodes.contains(detectingCameraNode) {
                delegate.opponentsViewModel(self, didDetectOpponent: detectingCameraNode)
            }
        }

        for lastCameraNode in lastCameraNodes {
            if !detectingCameraNodes.contains(lastCameraNode) {
                delegate.opponentsViewModel(self, didEndDetectOpponent: lastCameraNode)
            }
        }

        return detectingCameraNodes
    }

    private func nodes(_ oppositionNodes: [OppositionNode],
                       thatSee synthoidNode: SynthoidNode,
                       in playerRenderer: SCNSceneRenderer) -> [OppositionNode] {
        var detectingOppositionNodes: [OppositionNode] = []
        for oppositionNode in oppositionNodes {
            let detectableSynthoids = oppositionNode.visibleSynthoids(in: playerRenderer)
            if detectableSynthoids.contains(synthoidNode) {
                detectingOppositionNodes.append(oppositionNode)
            }
        }
        return detectingOppositionNodes
    }
}
