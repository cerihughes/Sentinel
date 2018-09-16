import SceneKit

class NodeMap: NSObject {
    private var nodeMap: [FloorNode:GridPiece] = [:]
    private var pointMap: [GridPoint:FloorNode] = [:]

    func add(floorNode: FloorNode, for piece: GridPiece) {
        nodeMap[floorNode] = piece
        pointMap[piece.point] = floorNode
    }

    func getPiece(for floorNode: FloorNode) -> GridPiece? {
        return nodeMap[floorNode]
    }

    func getFloorNode(for point: GridPoint) -> FloorNode? {
        return pointMap[point]
    }
}
