import Foundation
import SceneKit

extension Array where Element == SCNHitTestResult {
    func firstInteractiveNode() -> SCNNode? {
        for result in self {
            let node = result.node
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
