import SceneKit

protocol GameInputHandler {
    var playerOperations: PlayerOperations {get}
    var opponentsOperations: OpponentsOperations {get}

    func addGestureRecognisers(to view: UIView)
    func setGestureRecognisersEnabled(_ isEnabled: Bool)
}

extension GameInputHandler {
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
