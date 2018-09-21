import SceneKit

class WorldManipulator: NSObject, NodeOperations {
    let playerNodeManipulator: NodeManipulator
    let opponentNodeManipulator: NodeManipulator

    init(playerNodeManipulator: NodeManipulator, opponentNodeManipulator: NodeManipulator) {
        self.playerNodeManipulator = playerNodeManipulator
        self.opponentNodeManipulator = opponentNodeManipulator

        super.init()
    }

    func viewingNode(for viewer: Viewer) -> ViewingNode? {
        switch viewer {
        case .player:
            return playerNodeManipulator.currentSynthoidNode
        case .sentinel:
            return opponentNodeManipulator.terrainNode.sentinelNode
        default:
            let sentryNodes = opponentNodeManipulator.terrainNode.sentryNodes
            let rawValueOffset = Viewer.sentry1.rawValue
            let index = viewer.rawValue - rawValueOffset
            if index < sentryNodes.count {
                return sentryNodes[index]
            }
            return nil
        }
    }

    func opponentOppositionNode(at point: GridPoint) -> OppositionNode? {
        guard let opponentFloorNode = opponentNodeManipulator.floorNode(for: point) else {
            return nil
        }
        return opponentFloorNode.sentinelNode ?? opponentFloorNode.sentryNode
    }

    // MARK: NodeOperations

    var currentSynthoidNode: SynthoidNode? {
        return playerNodeManipulator.currentSynthoidNode
    }

    func rotateAllOpposition(by radians: Float, duration: TimeInterval) {
        playerNodeManipulator.rotateAllOpposition(by: radians, duration: duration)
        opponentNodeManipulator.rotateAllOpposition(by: radians, duration: duration)
    }

    func rotateCurrentSynthoid(by radiansDelta: Float, persist: Bool = false) {
        playerNodeManipulator.rotateCurrentSynthoid(by: radiansDelta, persist: persist)
        opponentNodeManipulator.rotateCurrentSynthoid(by: radiansDelta, persist: persist)
    }

    func makeSynthoidCurrent(at point: GridPoint) {
        playerNodeManipulator.makeSynthoidCurrent(at: point)
        opponentNodeManipulator.makeSynthoidCurrent(at: point)
    }

    func buildTree(at point: GridPoint) {
        playerNodeManipulator.buildTree(at: point)
        opponentNodeManipulator.buildTree(at: point)
    }

    func buildRock(at point: GridPoint) {
        playerNodeManipulator.buildRock(at: point)
        opponentNodeManipulator.buildRock(at: point)
    }

    func buildSynthoid(at point: GridPoint, viewingAngle: Float) {
        playerNodeManipulator.buildSynthoid(at: point, viewingAngle: viewingAngle)
        opponentNodeManipulator.buildSynthoid(at: point, viewingAngle: viewingAngle)
    }

    func absorbTree(at point: GridPoint) -> Bool {
        _ = playerNodeManipulator.absorbTree(at: point)
        return opponentNodeManipulator.absorbTree(at: point)
    }

    func absorbRock(at point: GridPoint, height: Int) -> Bool {
        _ = playerNodeManipulator.absorbRock(at: point, height: height)
        return opponentNodeManipulator.absorbRock(at: point, height: height)
    }

    func absorbSynthoid(at point: GridPoint) -> Bool {
        _ = playerNodeManipulator.absorbSynthoid(at: point)
        return opponentNodeManipulator.absorbSynthoid(at: point)
    }

    func absorbSentry(at point: GridPoint) -> Bool {
        _ = playerNodeManipulator.absorbSentry(at: point)
        return opponentNodeManipulator.absorbSentry(at: point)
    }

    func absorbSentinel(at point: GridPoint) -> Bool {
        _ = playerNodeManipulator.absorbSentinel(at: point)
        return opponentNodeManipulator.absorbSentinel(at: point)
    }
}
