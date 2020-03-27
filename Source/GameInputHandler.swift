import SceneKit

/**
 The game input handler allows experimentation with different input mechanisms. The implementation will be made up of
 a number of UIGestureRecognisers, and its job is to translate gestures into invocations on playerOperations or
 opponentsOperations.

 The "owning" view will be passed into the addGestureReconisers(view:) call, and these should be enabled / disabled on
 calls to setGestureRecognisersEnabled(_:)
 */
protocol GameInputHandler {
    var playerOperations: PlayerOperations { get }
    var opponentsOperations: OpponentsOperations { get }

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
