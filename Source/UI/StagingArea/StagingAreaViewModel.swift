import SceneKit

class StagingAreaViewModel {
    let scene: SCNScene
    let initialCameraNode: SCNNode

    init() {
        scene = SCNScene()

        let opponentNode = SentinelNode(floorSize: 10.0, detectionRadius: 100.0)

        scene.rootNode.addChildNode(opponentNode)

        initialCameraNode = opponentNode.cameraNode
    }
}
