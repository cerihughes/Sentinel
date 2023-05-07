import SceneKit

class StagingAreaViewModel {
    let scene: SCNScene
    let initialCameraNode: SCNNode

    init() {
        scene = SCNScene()

        let opponentNode = SentinelNode(detectionRadius: 100.0)

        scene.rootNode.addChildNode(opponentNode)

        initialCameraNode = opponentNode.cameraNode
    }
}
