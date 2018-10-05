import SceneKit

class NodeManipulator: NSObject {
    let terrainNode: TerrainNode
    private let nodeMap: NodeMap
    let nodeFactory: NodeFactory

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

    func buildTree(at point: GridPoint) {
        guard let floorNode = nodeMap.getFloorNode(for: point) else {
            return
        }

        let treeNode = nodeFactory.createTreeNode(height: floorNode.rockNodes.count)
        floorNode.treeNode = treeNode
    }

    func buildRock(at point: GridPoint, rotation: Float? = nil) {
        guard let floorNode = nodeMap.getFloorNode(for: point) else {
            return
        }

        if floorNode.treeNode != nil {
            _ = absorbTree(at: point)
        }

        let rockNode = nodeFactory.createRockNode(height: floorNode.rockNodes.count, rotation: rotation)
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

    func absorbRock(at point: GridPoint) -> Bool {
        guard
            let floorNode = nodeMap.getFloorNode(for: point),
            floorNode.treeNode == nil,
            floorNode.synthoidNode == nil
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

