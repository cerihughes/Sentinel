import SceneKit

class SpaceWorld: World {
    func buildWorld(in scene: SCNScene, around terrainNode: TerrainNode) {
        let orbitNode = createOrbitNode()
        orbitNode.addChildNode(terrainNode)
        scene.rootNode.addChildNode(orbitNode)

        let skyBox = SkyBox(sourceImage: #imageLiteral(resourceName: "skybox.png"))
        if let components = skyBox.componentImages() {
            scene.background.contents = components
        }
        scene.rootNode.addSunLight()
    }

    private func createOrbitNode() -> SCNNode {
        let orbitNode = SCNNode()
        orbitNode.name = "orbitNodeName"
        orbitNode.rotation = SCNVector4Make(0.38, 0.42, 0.63, 0.0)
        let orbit = CABasicAnimation(keyPath: "rotation.w")
        orbit.byValue = Float.pi * -2.0
        orbit.duration = 120.0
        orbit.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        orbit.repeatCount = Float.infinity
        orbitNode.addAnimation(orbit, forKey: "orbit")
        orbitNode.addAmbientLight()
        return orbitNode
    }
}

private extension SCNNode {
    func addSunLight() {
        let lightNode = createLightNode(colourLevel: 1, type: .omni)
        lightNode.position = SCNVector3Make(-1200, 1000, -1200)
        addChildNode(lightNode)
    }

    func addAmbientLight() {
        let lightNode = createLightNode(colourLevel: 0.75, type: .omni)
        lightNode.position = SCNVector3Make(0, 500, 0)
        addChildNode(lightNode)
    }

    func createLightNode(colourLevel: CGFloat, type: SCNLight.LightType) -> SCNNode {
        let light = SCNLight()
        light.type = type
        light.color = UIColor(red: colourLevel, green: colourLevel, blue: colourLevel, alpha: colourLevel)
        let node = SCNNode()
        node.name = ambientLightNodeName
        node.light = light
        return node
    }
}
