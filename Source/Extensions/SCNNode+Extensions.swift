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

// Animation extensions

extension CFTimeInterval {
    static let animationDuration = CFTimeInterval(0.3)
}

extension SCNNode {
    func scaleAllDimensions(by scale: Float) {
        let angle = Float.pi * 8.0 * scale
        let position = self.position
        transform = SCNMatrix4MakeRotation(angle, 0, 1, 0)
        self.position = position
        self.scale = SCNVector3Make(scale, scale, scale)
    }

    func scaleAllDimensions(by scale: Float, animated: Bool, completion: (() -> Void)? = nil) {
        guard animated else {
            scaleAllDimensions(by: scale)
            completion?()
            return
        }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = .animationDuration
        SCNTransaction.completionBlock = {
            completion?()
        }

        scaleAllDimensions(by: scale)

        SCNTransaction.commit()
    }

    func scaleDownAndRemove(animated: Bool, completion: (() -> Void)? = nil) {
        guard animated else {
            removeFromParentNode()
            completion?()
            return
        }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = .animationDuration
        SCNTransaction.completionBlock = { [weak self] in
            self?.removeFromParentNode()
            completion?()
        }

        scaleAllDimensions(by: 0.0)

        SCNTransaction.commit()
    }

    func alphaDownAndRemove(animated: Bool, completion: (() -> Void)? = nil) {
        guard animated else {
            removeFromParentNode()
            completion?()
            return
        }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = .animationDuration
        SCNTransaction.completionBlock = { [weak self] in
            self?.removeFromParentNode()
            completion?()
        }

        geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.0)

        SCNTransaction.commit()
    }
}
