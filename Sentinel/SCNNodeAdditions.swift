import SceneKit

extension SCNNode {
    func treeNode() -> SCNNode? {
        return childNode(withName: treeNodeName, recursively: false)
    }

    func removeTreeNode() -> SCNNode? {
        guard let existing = treeNode() else {
            return nil
        }

        existing.removeFromParentNode()
        return existing
    }

    func rockNodes() -> [SCNNode] {
        return childNodes.filter( { $0.name != nil && $0.name! == rockNodeName } )
    }

    func synthoidNode() -> SCNNode? {
        return childNode(withName: synthoidNodeName, recursively: false)
    }

    func removeLastRockNode() -> SCNNode? {
        guard let last = rockNodes().last else {
            return nil
        }

        last.removeFromParentNode()
        return last
    }
}
