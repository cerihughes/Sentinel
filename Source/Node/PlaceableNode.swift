import SceneKit

protocol PlaceableNode {
    var floorNode: FloorNode? { get }
}

typealias PlaceableSCNNode = PlaceableNode & SCNNode
