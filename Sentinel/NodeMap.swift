import SceneKit

class NodeMap: NSObject {
    private var nodeMap: [SCNNode:GridPiece] = [:]
    private var pointMap: [GridPoint:SCNNode] = [:]

    func add(node: SCNNode, for piece: GridPiece) {
        nodeMap[node] = piece
        pointMap[piece.point] = node
    }

    func getPiece(for node: SCNNode) -> GridPiece? {
        return nodeMap[node]
    }

    func getNode(for point: GridPoint) -> SCNNode? {
        return pointMap[point]
    }
}
