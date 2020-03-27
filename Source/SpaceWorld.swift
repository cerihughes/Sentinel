import SceneKit

class SpaceWorld: World {
    private let nodeFactory: NodeFactory
    internal let initialCameraNode: SCNNode
    internal let scene = SCNScene()

    private let orbitNode = SCNNode()

    init(nodeFactory: NodeFactory) {
        self.nodeFactory = nodeFactory
        self.initialCameraNode = nodeFactory.createCameraNode()

        setupScene()
    }

    private func setupScene() {
        let skyBox = SkyBox(sourceImage: #imageLiteral(resourceName: "skybox.png"))
        if let components = skyBox.componentImages() {
            scene.background.contents = components
        }

        initialCameraNode.position = SCNVector3Make(25.0, 200.0, 225.0)

        orbitNode.name = "orbitNodeName"
        orbitNode.rotation = SCNVector4Make(0.38, 0.42, 0.63, 0.0)
        let orbit = CABasicAnimation(keyPath: "rotation.w")
        orbit.byValue = Float.pi * -2.0
        orbit.duration = 100.0
        orbit.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        orbit.repeatCount = Float.infinity
        orbitNode.addAnimation(orbit, forKey: "orbit")

        orbitNode.addChildNode(initialCameraNode)
        addAmbientLights(to: orbitNode)

        scene.rootNode.addChildNode(orbitNode)
    }

    private func addAmbientLights(to node: SCNNode) {
        let ambientLightNodes = nodeFactory.createAmbientLightNodes(distance: 200.0)

        for ambientLightNode in ambientLightNodes {
            node.addChildNode(ambientLightNode)
        }
    }

    func set(terrainNode: TerrainNode) {
        orbitNode.addChildNode(terrainNode)
        initialCameraNode.look(at: terrainNode.worldPosition)
    }
}
