import SceneKit

protocol InputViewModel {
    func addGestureRecognisers(to view: UIView)
}

extension InputViewModel {
    func firstInteractiveNode(for hitTestResults: [SCNHitTestResult]) -> SCNNode? {
        for hitTestResult in hitTestResults {
            let node = hitTestResult.node
            if let interactiveParentInfo = node.findInteractiveParent() {
                if interactiveParentInfo.bitMask == interactiveNodeBitMask {
                    return interactiveParentInfo.node
                }

                if interactiveParentInfo.bitMask == noninteractiveBlockingNodeBitMask {
                    return nil
                }

                // if it's noninteractiveTransparetnNodeBitMask, the loop continues
            }
        }
        return nil
    }
}
