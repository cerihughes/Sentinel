import SceneKit

class NodeManipulator: NSObject, NodeOperations {
    let terrainNode: TerrainNode
    private let nodeMap: NodeMap
    private let nodeFactory: NodeFactory

    var currentSynthoidNode: SynthoidNode?

    init(terrainNode: TerrainNode, nodeMap: NodeMap, nodeFactory: NodeFactory) {
        self.terrainNode = terrainNode
        self.nodeMap = nodeMap
        self.nodeFactory = nodeFactory

        super.init()
    }

    // TODO: Should these methods be in a different place? Maybe this class shouldn't know about the node map?
    func synthoidNode(at point: GridPoint) -> SynthoidNode? {
        return nodeMap.getFloorNode(for: point)?.synthoidNode
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

    func rotateAllOpposition(by radians: Float, duration: TimeInterval) {
        for oppositionNode in terrainNode.oppositionNodes {
            oppositionNode.rotate(by: radians, duration: duration)
        }
    }

    func rotateCurrentSynthoid(by radiansDelta: Float, persist: Bool) {
        guard let synthoidNode = currentSynthoidNode else {
            return
        }

        synthoidNode.apply(rotationDelta: radiansDelta, persist: persist)
    }

    func buildTree(at point: GridPoint) {
        guard let floorNode = nodeMap.getFloorNode(for: point) else {
            return
        }

        let treeNode = nodeFactory.createTreeNode(height: floorNode.rockNodes.count)
        floorNode.treeNode = treeNode
    }

    func buildRock(at point: GridPoint) {
        guard let floorNode = nodeMap.getFloorNode(for: point) else {
            return
        }

        if floorNode.treeNode != nil {
            _ = absorbTree(at: point)
        }

        let rockNode = nodeFactory.createRockNode(height: floorNode.rockNodes.count)
        floorNode.add(rockNode: rockNode)
    }

    func buildSynthoid(at point: GridPoint, viewingAngle: Float) {
        guard let floorNode = nodeMap.getFloorNode(for: point) else {
            return
        }

        let synthoidNode = nodeFactory.createSynthoidNode(height: floorNode.rockNodes.count, viewingAngle: viewingAngle)
        floorNode.synthoidNode = synthoidNode
    }

    func absorbTree(at point: GridPoint) -> Bool {
        return absorb(node: nodeMap.getFloorNode(for: point)?.treeNode)
    }

    func absorbRock(at point: GridPoint, height: Int) -> Bool {
        guard
            let floorNode = nodeMap.getFloorNode(for: point),
            floorNode.rockNodes.count > height
            else {
                return false
        }
        return absorb(node: floorNode.rockNodes.last)
    }

    func absorbSynthoid(at point: GridPoint) -> Bool {
        return absorb(node: nodeMap.getFloorNode(for: point)?.synthoidNode)
    }

    func absorbSentry(at point: GridPoint) -> Bool {
        return absorb(node: nodeMap.getFloorNode(for: point)?.sentryNode)
    }

    func absorbSentinel(at point: GridPoint) -> Bool {
        return absorb(node: nodeMap.getFloorNode(for: point)?.sentinelNode)
    }

    private func absorb(node: SCNNode?) -> Bool {
        if let node = node {
            node.removeFromParentNode()
            return true
        }
        return false
    }
}

