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

    let timeMachine = TimeMachine()

    init(levelConfiguration: LevelConfiguration, terrainViewModel: TerrainViewModel) {
        self.levelConfiguration = levelConfiguration
        self.terrainViewModel = terrainViewModel

        self.nodeManipulator = terrainViewModel.nodeManipulator
        self.grid = terrainViewModel.grid

        super.init()

        setupTimingFunctions()
    }

    private func buildRandomTree() {
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
        _ = timeMachine.add(timeInterval: 2.0, function: absorbObjects(timeInterval:playerRenderer:lastResult:))
        _ = timeMachine.add(timeInterval: levelConfiguration.opponentRotationPause, function: rotation(timeInterval:playerRenderer:lastResult:))
        _ = timeMachine.add(timeInterval: 2.0, function: detection(timeInterval:playerRenderer:lastResult:))
    }

    private func absorbObjects(timeInterval: TimeInterval, playerRenderer: SCNSceneRenderer, lastResult: Any?) -> Any? {
        guard let synthoidNode = nodeManipulator.currentSynthoidNode else {
            return nil
        }

        for opponentNode in nodeManipulator.terrainNode.opponentNodes {
            // Don't absorb the player - this is handled by a separate timing function
            let visibleSynthoids = opponentNode.visibleSynthoids(in: playerRenderer).filter { $0 != synthoidNode }

            if let visibleSynthoid = visibleSynthoids.randomElement(),
                let floorNode = visibleSynthoid.floorNode,
                let point = nodeManipulator.point(for: floorNode) {
                if terrainViewModel.absorbSynthoidNode(at: point) {
                    terrainViewModel.buildRock(at: point)
                    buildRandomTree()
                    return nil
                }
            }

            if let visibleRock = opponentNode.visibleRocks(in: playerRenderer).randomElement(),
                let floorNode = visibleRock.floorNode,
                let point = nodeManipulator.point(for: floorNode) {
                if terrainViewModel.absorbRockNode(at: point, isFinalRockNode: floorNode.rockNodes.count == 1) {
                    terrainViewModel.buildTree(at: point)
                    buildRandomTree()
                    return nil
                }
            }

            if let visibleTree = opponentNode.visibleTreesOnRocks(in: playerRenderer).randomElement(),
                let floorNode = visibleTree.floorNode,
                let point = nodeManipulator.point(for: floorNode) {
                if terrainViewModel.absorbTreeNode(at: point) {
                    buildRandomTree()
                    return nil
                }
            }
        }
        return nil
    }

    private func rotation(timeInterval: TimeInterval, playerRenderer: SCNSceneRenderer, lastResult: Any?) -> Any? {
        let radians = 2.0 * Float.pi / Float(levelConfiguration.opponentRotationSteps)
        let duration = levelConfiguration.opponentRotationTime
        nodeManipulator.rotateAllOpponents(by: radians, duration: duration)
        return nil
    }

    private func detection(timeInterval: TimeInterval, playerRenderer: SCNSceneRenderer, lastResult: Any?) -> Any? {
        guard
            let delegate = delegate,
            let synthoidNode = nodeManipulator.currentSynthoidNode
            else {
                return lastResult
        }

        let opponentNodes = nodeManipulator.terrainNode.opponentNodes
        let detectingOpponentNodes = nodes(opponentNodes, thatSee: synthoidNode, in: playerRenderer)
        let detectingCameraNodes = Set(detectingOpponentNodes.map { $0.cameraNode })
        let lastCameraNodes = lastResult as? Set<SCNNode> ?? []
        if detectingCameraNodes.intersection(lastCameraNodes).count > 0 {
            // Seen by a camera for more than 1 "cycle"...
            delegate.opponentsViewModelDidDepleteEnergy(self)
            buildRandomTree()
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

    private func nodes(_ opponentNodes: [OpponentNode],
                       thatSee synthoidNode: SynthoidNode,
                       in playerRenderer: SCNSceneRenderer) -> [OpponentNode] {
        var detectingOpponentNodes: [OpponentNode] = []
        for opponentNode in opponentNodes {
            let detectableSynthoids = opponentNode.visibleSynthoids(in: playerRenderer)
            if detectableSynthoids.contains(synthoidNode) {
                detectingOpponentNodes.append(opponentNode)
            }
        }
        return detectingOpponentNodes
    }
}
