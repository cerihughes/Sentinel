import SceneKit

protocol OpponentsOperationsDelegate: AnyObject {
    func opponentsOperationsDidAbsorb(_ opponentsOperations: OpponentsOperations)
    func opponentsOperationsDidDepleteEnergy(_ opponentsOperations: OpponentsOperations) -> Bool
    func opponentsOperations(_ opponentsOperations: OpponentsOperations, didDetectOpponent cameraNode: SCNNode)
    func opponentsOperations(_ opponentsOperations: OpponentsOperations, didEndDetectOpponent cameraNode: SCNNode)
}

class OpponentsOperations {
    private let terrainOperations: TerrainOperations
    private let timeMachine: TimeMachine

    weak var delegate: OpponentsOperationsDelegate?

    init(terrainOperations: TerrainOperations, timeMachine: TimeMachine) {
        self.terrainOperations = terrainOperations
        self.timeMachine = timeMachine

        setupTimingFunctions()
    }

    private var nodeMap: NodeMap { terrainOperations.nodeMap }
    private var nodeManipulator: NodeManipulator { terrainOperations.nodeManipulator }

    private func buildRandomTree() {
        let emptyPieces = terrainOperations.grid.emptyFloorPieces()
        if let randomPiece = emptyPieces.randomElement() {
            terrainOperations.buildTree(at: randomPiece.point, animated: true)
        }
    }

    private func setupTimingFunctions() {
        timeMachine.add(
            timeInterval: .animationDuration * 2.0,
            function: absorbObjects(timeInterval:renderer:lastResult:)
        )
        timeMachine.add(timeInterval: 8.0, function: rotation(timeInterval:renderer:lastResult:))
        timeMachine.add(timeInterval: 2.0, function: detection(timeInterval:renderer:lastResult:))
    }

    private func absorbObjects(timeInterval: TimeInterval, renderer: SCNSceneRenderer, lastResult: Any?) -> Any? {
        guard let synthoidNode = nodeManipulator.currentSynthoidNode else { return nil }

        for opponentNode in nodeManipulator.terrainNode.opponentNodes {
            // Don't absorb the player - this is handled by a separate timing function
            let visibleSynthoidPoints = opponentNode.visibleSynthoids(in: renderer).filter { $0 != synthoidNode }
                .compactMap { $0.floorNode }
                .compactMap { nodeMap.point(for: $0) }
                .sortedByDistance(from: terrainOperations.grid.sentinelPosition, ascending: true)

            if let visibleSynthoidPoint = visibleSynthoidPoints.first {
                terrainOperations.showAbsorption(from: opponentNode, to: visibleSynthoidPoint)
                terrainOperations.absorbSynthoidNode(at: visibleSynthoidPoint, animated: true)
                terrainOperations.buildRock(at: visibleSynthoidPoint, animated: true)
                buildRandomTree()
                delegate?.opponentsOperationsDidAbsorb(self)
                return nil
            }

            let visibleRockPoints = opponentNode.visibleRocks(in: renderer)
                .compactMap { $0.floorNode }
                .compactMap { nodeMap.point(for: $0) }
                .sortedByDistance(from: terrainOperations.grid.sentinelPosition, ascending: true)

            if let visibleRockPoint = visibleRockPoints.first {
                terrainOperations.showAbsorption(from: opponentNode, to: visibleRockPoint)
                terrainOperations.absorbRockNode(at: visibleRockPoint, animated: true)
                terrainOperations.buildTree(at: visibleRockPoint, animated: true)
                buildRandomTree()
                delegate?.opponentsOperationsDidAbsorb(self)
                return nil
            }

            let visibleTreePoints = opponentNode.visibleTreesOnRocks(in: renderer)
                .compactMap { $0.floorNode }
                .compactMap { nodeMap.point(for: $0) }
                .sortedByDistance(from: terrainOperations.grid.sentinelPosition, ascending: true)

            if let visibleTreePoint = visibleTreePoints.first {
                terrainOperations.showAbsorption(from: opponentNode, to: visibleTreePoint)
                terrainOperations.absorbTreeNode(at: visibleTreePoint, animated: true)
                buildRandomTree()
                delegate?.opponentsOperationsDidAbsorb(self)
                return nil
            }
        }
        return nil
    }

    private func rotation(timeInterval: TimeInterval, renderer: SCNSceneRenderer, lastResult: Any?) -> Any? {
        let radians = 2.0 * Float.pi / 12.0 // 12 rotation "steps"
        for opponentNode in nodeManipulator.terrainNode.opponentNodes {
            guard opponentNode.hasVisibleItemsToAbsorb(in: renderer) == false else { continue }
            nodeManipulator.rotate(opponentNode: opponentNode, by: radians)
        }
        return nil
    }

    private func detection(timeInterval: TimeInterval, renderer: SCNSceneRenderer, lastResult: Any?) -> Any? {
        guard let delegate, let synthoidNode = nodeManipulator.currentSynthoidNode else { return lastResult }

        let opponentNodes = nodeManipulator.terrainNode.opponentNodes
        let detectingOpponentNodes = nodes(opponentNodes, thatSee: synthoidNode, in: renderer)
        let detectingCameraNodes = Set(detectingOpponentNodes.map { $0.cameraNode })
        let lastCameraNodes = lastResult as? Set<SCNNode> ?? []
        if !detectingCameraNodes.isDisjoint(with: lastCameraNodes) {
            // Seen by a camera for more than 1 "cycle"...
            if delegate.opponentsOperationsDidDepleteEnergy(self) {
                buildRandomTree()
            }
        }

        detectingCameraNodes.forEach {
            if !lastCameraNodes.contains($0) {
                delegate.opponentsOperations(self, didDetectOpponent: $0)
            }
        }

        lastCameraNodes.forEach {
            if !detectingCameraNodes.contains($0) {
                delegate.opponentsOperations(self, didEndDetectOpponent: $0)
            }
        }

        return detectingCameraNodes
    }

    private func nodes(
        _ opponentNodes: [OpponentNode],
        thatSee synthoidNode: SynthoidNode,
        in renderer: SCNSceneRenderer
    ) -> [OpponentNode] {
        var detectingOpponentNodes: [OpponentNode] = []
        for opponentNode in opponentNodes {
            let detectableSynthoids = opponentNode.visibleSynthoids(in: renderer)
            if detectableSynthoids.contains(synthoidNode) {
                detectingOpponentNodes.append(opponentNode)
            }
        }
        return detectingOpponentNodes
    }
}

private extension ViewingNode {
    func hasVisibleItemsToAbsorb(in renderer: SCNSceneRenderer) -> Bool {
        if visibleSynthoids(in: renderer).isNotEmpty {
            return true
        }
        if visibleRocks(in: renderer).isNotEmpty {
            return true
        }
        if visibleTreesOnRocks(in: renderer).isNotEmpty {
            return true
        }
        return false
    }
}

private extension Collection {
    var isNotEmpty: Bool { !isEmpty }
}
