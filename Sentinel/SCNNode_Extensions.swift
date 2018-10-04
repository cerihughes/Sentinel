import SceneKit

extension SCNNode {
    func firstPlaceableParent() -> PlaceableNode? {
        var placeableNode: SCNNode? = self
        while placeableNode != nil && placeableNode as? PlaceableNode == nil {
            placeableNode = placeableNode?.parent
        }
        return placeableNode as? PlaceableNode
    }

    func firstInteractiveParent() -> SCNNode? {
        var interactiveNode = self
        while interactiveNode.categoryBitMask & interactiveNodeBitMask == 0 {
            if interactiveNode.categoryBitMask & noninteractiveNodeBitMask != 0 {
                return nil
            }

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
