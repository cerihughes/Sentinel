import SceneKit

class NodeMap: NSObject {
    private var nodeMap: [SCNNode:GridPiece] = [:]

    func add(node: SCNNode, for piece: GridPiece) {
        nodeMap[node] = piece
    }

    func getPiece(for node: SCNNode) -> GridPiece? {
        return nodeMap[node]
    }
}
