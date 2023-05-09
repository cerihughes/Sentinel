import SceneKit

class NodeMap {
    private var nodeMap: [FloorNode: GridPiece] = [:]
    private var pointMap: [GridPoint: FloorNode] = [:]

    func add(floorNode: FloorNode, for piece: GridPiece) {
        nodeMap[floorNode] = piece
        pointMap[piece.point] = floorNode
    }

    func piece(for floorNode: FloorNode) -> GridPiece? {
        nodeMap[floorNode]
    }

    func floorNode(at point: GridPoint) -> FloorNode? {
        pointMap[point]
    }
}

extension NodeMap {
    func canBuild(at point: GridPoint) -> Bool {
        guard
            let floorNode = floorNode(at: point),
            floorNode.treeNode == nil,
            floorNode.synthoidNode == nil,
            floorNode.sentryNode == nil,
            floorNode.sentinelNode == nil
        else {
            return false
        }
        return true
    }

    func synthoidNode(at point: GridPoint) -> SynthoidNode? {
        floorNode(at: point)?.synthoidNode
    }

    func opponentNode(at point: GridPoint) -> OpponentNode? {
        guard let floorNode = floorNode(at: point) else { return nil }
        return floorNode.sentinelNode ?? floorNode.sentryNode
    }

    func point(for floorNode: FloorNode) -> GridPoint? {
        piece(for: floorNode).map { $0.point }
    }
}
