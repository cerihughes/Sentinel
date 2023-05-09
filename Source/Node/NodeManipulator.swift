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
        nodeMap.getFloorNode(for: point)?.synthoidNode
    }

    func opponentNode(at point: GridPoint) -> OpponentNode? {
        guard let floorNode = nodeMap.getFloorNode(for: point) else { return nil }
        return floorNode.sentinelNode ?? floorNode.sentryNode
    }

    func point(for floorNode: FloorNode) -> GridPoint? {
        nodeMap.getPiece(for: floorNode).map { $0.point }
    }

    func makeSynthoidCurrent(at point: GridPoint) {
        currentSynthoidNode = nodeMap.getFloorNode(for: point)?.synthoidNode
    }

    func floorNode(for point: GridPoint) -> FloorNode? {
        nodeMap.getFloorNode(for: point)
    }

    func rotate(opponentNode: OpponentNode, by radians: Float) {
        opponentNode.rotate(by: radians)
    }

    func rotateCurrentSynthoid(rotationDelta: Float, elevationDelta: Float, persist: Bool = false) {
        guard let synthoidNode = currentSynthoidNode else { return }
        synthoidNode.apply(rotationDelta: rotationDelta, elevationDelta: elevationDelta, persist: persist)
    }

    func buildTree(at point: GridPoint, height: Int, animated: Bool, completion: (() -> Void)? = nil) {
        guard let floorNode = nodeMap.getFloorNode(for: point) else { return }
        let treeNode = nodeFactory.createTreeNode(height: height)
        treeNode.scaleAllDimensions(by: 0.0)
        floorNode.treeNode = treeNode
        treeNode.scaleAllDimensions(by: 1.0, animated: animated, completion: completion)
    }

    func buildRock(
        at point: GridPoint,
        height: Int,
        rotation: Float? = nil,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        guard let floorNode = nodeMap.getFloorNode(for: point) else { return }
        let rockNode = nodeFactory.createRockNode(height: height, rotation: rotation)
        rockNode.scaleAllDimensions(by: 0.0)
        floorNode.add(rockNode: rockNode)
        rockNode.scaleAllDimensions(by: 1.0, animated: animated, completion: completion)
    }

    func buildSynthoid(at point: GridPoint, height: Int, viewingAngle: Float) {
        guard let floorNode = nodeMap.getFloorNode(for: point) else { return }
        let synthoidNode = nodeFactory.createSynthoidNode(height: height, viewingAngle: viewingAngle)
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
