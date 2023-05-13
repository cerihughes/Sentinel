import SceneKit

protocol DetectableNode {
    var detectionNodes: [SCNNode] { get }
}

typealias DetectableSCNNode = DetectableNode & SCNNode
