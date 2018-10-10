import SceneKit

protocol InputHandler {
    func addGestureRecognisers(to view: UIView)
}

extension InputHandler {
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
