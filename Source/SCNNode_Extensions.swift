import SceneKit

extension SCNNode {
    func firstPlaceableParent() -> PlaceableNode? {
        var placeableNode: SCNNode? = self
        while placeableNode != nil, placeableNode as? PlaceableNode == nil {
            placeableNode = placeableNode?.parent
        }
        return placeableNode as? PlaceableNode
    }

    func findInteractiveParent() -> (node: SCNNode, bitMask: Int)? {
        var interactiveNode = self
        while interactiveNode.isInteractive() == false {
            if interactiveNode.isNonInteractiveTransparent() {
                return (interactiveNode, noninteractiveTransparentNodeBitMask)
            }

            if interactiveNode.isNonInteractiveBlocking() {
                return (interactiveNode, noninteractiveBlockingNodeBitMask)
            }

            let parent = interactiveNode.parent
            if parent != nil {
                interactiveNode = parent!
            } else {
                return nil
            }
        }
        return (interactiveNode, interactiveNodeBitMask)
    }

    func isInteractive() -> Bool {
        return hasCategoryBit(bit: interactiveNodeBitMask)
    }

    func isNonInteractiveTransparent() -> Bool {
        return hasCategoryBit(bit: noninteractiveTransparentNodeBitMask)
    }

    func isNonInteractiveBlocking() -> Bool {
        return hasCategoryBit(bit: noninteractiveBlockingNodeBitMask)
    }

    private func hasCategoryBit(bit: Int) -> Bool {
        return categoryBitMask & bit != 0
    }
}
