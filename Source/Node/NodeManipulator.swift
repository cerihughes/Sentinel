import SceneKit

class NodeManipulator {
    let terrainNode: TerrainNode
    private let nodeMap: NodeMap
    let nodeFactory: NodeFactory
    var currentSynthoidNode: SynthoidNode?
    private let animatable: Bool

    init(terrainNode: TerrainNode, nodeMap: NodeMap, nodeFactory: NodeFactory, animatable: Bool) {
        self.terrainNode = terrainNode
        self.nodeMap = nodeMap
        self.nodeFactory = nodeFactory
        self.animatable = animatable
    }

    func synthoidNode(at point: GridPoint) -> SynthoidNode? {
        return nodeMap.getFloorNode(for: point)?.synthoidNode
    }

    func opponentNode(at point: GridPoint) -> OpponentNode? {
        if let floorNode = nodeMap.getFloorNode(for: point) {
            return floorNode.sentinelNode ?? floorNode.sentryNode
        }
        return nil
    }

    func point(for floorNode: FloorNode) -> GridPoint? {
        guard let piece = nodeMap.getPiece(for: floorNode) else {
            return nil
        }

        return piece.point
    }

    func makeSynthoidCurrent(at point: GridPoint) {
        currentSynthoidNode = nodeMap.getFloorNode(for: point)?.synthoidNode
    }

    func floorNode(for point: GridPoint) -> FloorNode? {
        return nodeMap.getFloorNode(for: point)
    }

    func rotateAllOpponents(by radians: Float, duration: TimeInterval) {
        for opponentNode in terrainNode.opponentNodes {
            opponentNode.rotate(by: radians, duration: duration)
        }
    }

    func rotateCurrentSynthoid(rotationDelta: Float, elevationDelta: Float, persist: Bool = false) {
        guard let synthoidNode = currentSynthoidNode else {
            return
        }

        synthoidNode.apply(rotationDelta: rotationDelta, elevationDelta: elevationDelta, persist: persist)
    }

    func buildTree(at point: GridPoint, animated: Bool, completion: (() -> Void)? = nil) {
        guard let floorNode = nodeMap.getFloorNode(for: point) else {
            return
        }

        let treeNode = nodeFactory.createTreeNode(height: floorNode.rockNodes.count)
        treeNode.scaleAllDimensions(by: 0.0)
        floorNode.treeNode = treeNode
        treeNode.scaleAllDimensions(by: 1.0, animated: animated, completion: completion)
    }

    func buildRock(at point: GridPoint, rotation: Float? = nil, animated: Bool, completion: (() -> Void)? = nil) {
        guard let floorNode = nodeMap.getFloorNode(for: point) else {
            return
        }

        let rockNode = nodeFactory.createRockNode(height: floorNode.rockNodes.count, rotation: rotation)
        rockNode.scaleAllDimensions(by: 0.0)
        floorNode.add(rockNode: rockNode)
        rockNode.scaleAllDimensions(by: 1.0, animated: animated, completion: completion)
    }

    func buildSynthoid(at point: GridPoint, viewingAngle: Float) {
        guard let floorNode = nodeMap.getFloorNode(for: point) else {
            return
        }

        let synthoidNode = nodeFactory.createSynthoidNode(height: floorNode.rockNodes.count, viewingAngle: viewingAngle)
        floorNode.synthoidNode = synthoidNode
    }

    func absorbTree(at point: GridPoint, animated: Bool, completion: (() -> Void)? = nil) {
        absorb(node: nodeMap.getFloorNode(for: point)?.treeNode, animated: animated, completion: completion)
    }

    func absorbRock(at point: GridPoint, animated: Bool, completion: (() -> Void)? = nil) {
        guard
            let floorNode = nodeMap.getFloorNode(for: point),
            floorNode.treeNode == nil,
            floorNode.synthoidNode == nil
        else {
            return
        }
        absorb(node: floorNode.rockNodes.last, animated: animated, completion: completion)
    }

    func absorbSynthoid(at point: GridPoint, animated: Bool, completion: (() -> Void)? = nil) {
        absorb(node: nodeMap.getFloorNode(for: point)?.synthoidNode, animated: animated, completion: completion)
    }

    func absorbSentry(at point: GridPoint, animated: Bool, completion: (() -> Void)? = nil) {
        absorb(node: nodeMap.getFloorNode(for: point)?.sentryNode, animated: animated, completion: completion)
    }

    func absorbSentinel(at point: GridPoint, animated: Bool, completion: (() -> Void)? = nil) {
        absorb(node: nodeMap.getFloorNode(for: point)?.sentinelNode, animated: animated, completion: completion)
    }

    private func absorb(node: SCNNode?, animated: Bool, completion: (() -> Void)? = nil) {
        guard let node else { return }
        node.removeFromParentNode(animated: animated && animatable, completion: completion)
    }
}
