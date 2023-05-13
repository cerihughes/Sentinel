import SceneKit

class NodeManipulator {
    let terrainNode: TerrainNode
    let nodeFactory: NodeFactory
    var currentSynthoidNode: SynthoidNode?
    private let animatable: Bool

    init(terrainNode: TerrainNode, nodeFactory: NodeFactory, animatable: Bool) {
        self.terrainNode = terrainNode
        self.nodeFactory = nodeFactory
        self.animatable = animatable
    }

    func rotate(opponentNode: OpponentNode, by radians: Float) {
        opponentNode.rotate(by: radians)
    }

    func rotateCurrentSynthoid(rotationDelta: Float, elevationDelta: Float, persist: Bool = false) {
        guard let synthoidNode = currentSynthoidNode else { return }
        synthoidNode.apply(rotationDelta: rotationDelta, elevationDelta: elevationDelta, persist: persist)
    }

    func buildTree(on floorNode: FloorNode, height: Int, animated: Bool, completion: (() -> Void)? = nil) {
        let treeNode = nodeFactory.createTreeNode(height: height)
        treeNode.scaleAllDimensions(by: 0.0)
        floorNode.treeNode = treeNode
        treeNode.scaleAllDimensions(by: 1.0, animated: animated, completion: completion)
    }

    func buildRock(
        on floorNode: FloorNode,
        height: Int,
        rotation: Float? = nil,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        let rockNode = nodeFactory.createRockNode(height: height, rotation: rotation)
        rockNode.scaleAllDimensions(by: 0.0)
        floorNode.add(rockNode: rockNode)
        rockNode.scaleAllDimensions(by: 1.0, animated: animated, completion: completion)
    }

    func buildSynthoid(on floorNode: FloorNode, height: Int, viewingAngle: Float) {
        let synthoidNode = nodeFactory.createSynthoidNode(height: height, viewingAngle: viewingAngle)
        floorNode.synthoidNode = synthoidNode
    }

    func absorbTree(on floorNode: FloorNode, animated: Bool, completion: (() -> Void)? = nil) {
        absorb(node: floorNode.treeNode, animated: animated, completion: completion)
    }

    func absorbRock(on floorNode: FloorNode, animated: Bool, completion: (() -> Void)? = nil) {
        guard floorNode.treeNode == nil, floorNode.synthoidNode == nil else { return }
        absorb(node: floorNode.rockNodes.last, animated: animated, completion: completion)
    }

    func absorbSynthoid(on floorNode: FloorNode, animated: Bool, completion: (() -> Void)? = nil) {
        absorb(node: floorNode.synthoidNode, animated: animated, completion: completion)
    }

    func absorbSentry(on floorNode: FloorNode, animated: Bool, completion: (() -> Void)? = nil) {
        absorb(node: floorNode.sentryNode, animated: animated, completion: completion)
    }

    func absorbSentinel(on floorNode: FloorNode, animated: Bool, completion: (() -> Void)? = nil) {
        absorb(node: floorNode.sentinelNode, animated: animated, completion: completion)
    }

    func showAbsorption(from source: SCNVector3, to point: GridPoint, height: Float) {
        let node = nodeFactory.createDetectionNode(from: source, to: point, height: height)
        terrainNode.addChildNode(node)
        node.alphaAndRemove(animated: true)
    }

    private func absorb(node: SCNNode?, animated: Bool, completion: (() -> Void)? = nil) {
        node?.removeFromParentNode(animated: animated && animatable, completion: completion)
    }
}
