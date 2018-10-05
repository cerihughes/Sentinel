import SceneKit

class StagingAreaViewModel: NSObject {
    let scene: SCNScene
    let initialCameraNode: SCNNode

    override init() {
        scene = SCNScene()

        let opponentNode = SentinelNode(floorSize: 10.0, detectionRadius: 100.0, options: [])

        scene.rootNode.addChildNode(opponentNode)

        initialCameraNode = opponentNode.cameraNode

        super.init()
    }
}
