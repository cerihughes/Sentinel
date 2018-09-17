import SceneKit

extension SCNNode {

    // TODO: Consolidate these 2 methods - do I still need the bitmask now that I have SCNNode subclasses?
    func firstPlaceableParent() -> PlaceableNode? {
        var placeableNode: SCNNode? = self
        while placeableNode != nil && placeableNode as? PlaceableNode == nil {
            placeableNode = placeableNode?.parent
        }
        return placeableNode as? PlaceableNode
    }

    func firstInteractiveParent() -> SCNNode? {
        var interactiveNode = self
        while interactiveNode.categoryBitMask < interactiveNodeType.floor.rawValue {
            let parent = interactiveNode.parent
            if (parent != nil) {
                interactiveNode = parent!
            } else {
                return nil
            }
        }
        return interactiveNode
    }
}
