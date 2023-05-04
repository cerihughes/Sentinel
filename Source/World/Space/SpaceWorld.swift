import SceneKit

class SpaceWorld: World {
    internal let scene = SCNScene()

    private let orbitNode = SCNNode()

    init() {
        setupScene()
    }

    func set(terrainNode: TerrainNode) {
        orbitNode.addChildNode(terrainNode)
    }

    private func setupScene() {
        let skyBox = SkyBox(sourceImage: #imageLiteral(resourceName: "skybox.png"))
        if let components = skyBox.componentImages() {
            scene.background.contents = components
        }

        orbitNode.name = "orbitNodeName"
        orbitNode.rotation = SCNVector4Make(0.38, 0.42, 0.63, 0.0)
        let orbit = CABasicAnimation(keyPath: "rotation.w")
        orbit.byValue = Float.pi * -2.0
        orbit.duration = 100.0
        orbit.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        orbit.repeatCount = Float.infinity
        orbitNode.addAnimation(orbit, forKey: "orbit")

        addAmbientLights(to: orbitNode)

        scene.rootNode.addChildNode(orbitNode)
    }

    private func addAmbientLights(to node: SCNNode) {
        let ambientLightNodes = createAmbientLightNodes(distance: 200.0)

        for ambientLightNode in ambientLightNodes {
            node.addChildNode(ambientLightNode)
        }
    }

    private func createAmbientLightNodes(distance: Float) -> [SCNNode] {
        var ambientLightNodes: [SCNNode] = []
        var ambientLightNode = createAmbientLightNode()
        for x in -1 ... 1 {
            for z in -1 ... 1 {
                if abs(x + z) == 1 {
                    continue
                }

                let xf = Float(x) * distance
                let yf = distance
                let zf = Float(z) * distance
                ambientLightNode.position = SCNVector3Make(xf, yf, zf)
                ambientLightNodes.append(ambientLightNode)

                ambientLightNode = ambientLightNode.clone()
            }
        }
        return ambientLightNodes
    }

    func createAmbientLightNode() -> SCNNode {
        let ambient = SCNLight()
        ambient.type = .omni
        ambient.color = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.75)
        let ambientNode = SCNNode()
        ambientNode.name = ambientLightNodeName
        ambientNode.light = ambient
        return ambientNode
    }
}
