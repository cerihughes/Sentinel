import SceneKit

extension SCNNode {
    func setTreeNode(node:SCNNode) {
        guard let parentName = name, parentName == floorNodeName,
            let childName = node.name, childName == treeNodeName else {
            return
        }

        _ = removeTreeNode()
        addChildNode(node)
    }

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

    func addRockNode(node: SCNNode) {
        guard let parentName = name, parentName == floorNodeName,
            let childName = node.name, childName == rockNodeName else {
            return
        }

        addChildNode(node)
    }

    func rockNodes() -> [SCNNode] {
        return childNodes.filter( { $0.name != nil && $0.name! == rockNodeName } )
    }

    func removeLastRockNode() -> SCNNode? {
        guard let last = rockNodes().last else {
            return nil
        }

        last.removeFromParentNode()
        return last
    }
}
