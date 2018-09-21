import SceneKit

class SpaceWorld: NSObject, World {
    private let nodeFactory: NodeFactory
    internal let initialCameraNode: SCNNode
    internal let playerScene = SCNScene()
    internal let opponentScene = SCNScene()

    private let orbitNode = SCNNode()

    init(nodeFactory: NodeFactory) {
        self.nodeFactory = nodeFactory
        self.initialCameraNode = nodeFactory.createCameraNode()
        super.init()

        setupPlayerScene()
        setupOpponentScene()
    }

    private func setupPlayerScene() {
        let skyBox = SkyBox(sourceImage: #imageLiteral(resourceName: "skybox.png"))
        if let components = skyBox.componentImages() {
            playerScene.background.contents = components
        }

        initialCameraNode.position = SCNVector3Make(25.0, 200.0, 225.0)

        let ambientLightNodes = nodeFactory.createAmbientLightNodes(distance: 200.0)
        orbitNode.name = "orbitNodeName"
        orbitNode.rotation = SCNVector4Make(0.38, 0.42, 0.63, 0.0)
        let orbit = CABasicAnimation(keyPath: "rotation.w")
        orbit.byValue = Float.pi * -2.0
        orbit.duration = 100.0
        orbit.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        orbit.repeatCount = Float.infinity
        orbitNode.addAnimation(orbit, forKey: "orbit")

        orbitNode.addChildNode(initialCameraNode)
        for ambientLightNode in ambientLightNodes {
            orbitNode.addChildNode(ambientLightNode)
        }

        playerScene.rootNode.addChildNode(orbitNode)
    }

    private func setupOpponentScene() {
        let ambientLightNodes = nodeFactory.createAmbientLightNodes(distance: 200.0)

        for ambientLightNode in ambientLightNodes {
            opponentScene.rootNode.addChildNode(ambientLightNode)
        }
    }

    func set(playerTerrainNode: TerrainNode, opponentTerrainNode: TerrainNode) {
        orbitNode.addChildNode(playerTerrainNode)
        opponentScene.rootNode.addChildNode(opponentTerrainNode)
        initialCameraNode.look(at: playerTerrainNode.worldPosition)
    }
}
