import SceneKit

class ViewController: UIViewController {

    var terrainIndex = 0
    var terrainNode = SCNNode()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let sceneView = self.view as? SCNView else {
            return
        }

        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor(white: 0.7, alpha: 1.0)

        let scene = SCNScene()
        sceneView.scene = scene

        createTerrain(in: scene)

        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(25.0, 200.0, 225.0)
        camera.zNear = 100.0
        camera.zFar = 500.0
        cameraNode.constraints = [SCNLookAtConstraint(target: terrainNode)]
        scene.rootNode.addChildNode(cameraNode)

        let omni = SCNLight()
        omni.type = .omni
        omni.color = UIColor(red: 0.4, green: 0.3, blue: 0.3, alpha: 1.0)
        let omniNode = SCNNode()
        omniNode.light = omni
        omniNode.position = SCNVector3Make(100, 200, 100)
        scene.rootNode.addChildNode(omniNode)

        let sun = SCNLight()
        sun.type = .spot
        sun.color = UIColor(white: 0.9, alpha: 1.0)
        sun.castsShadow = true
        sun.shadowRadius = 50.0
        sun.shadowColor = UIColor(white: 0.0, alpha: 0.75)
        sun.zNear = 300.0
        sun.zFar = 700.0
        sun.attenuationStartDistance = 300.0
        sun.attenuationEndDistance = 700.0
        let sunNode = SCNNode()
        sunNode.light = sun
        sunNode.position = SCNVector3Make(5.0, 500.0, -5.0)
        sunNode.constraints = [SCNLookAtConstraint(target: terrainNode)]

        let moon = SCNLight()
        moon.type = .spot
        moon.color = UIColor(white: 0.5, alpha: 1.0)
        moon.castsShadow = true
        moon.shadowRadius = 3.0
        moon.shadowColor = UIColor(white: 0.0, alpha: 0.75)
        moon.zNear = 300.0
        moon.zFar = 700.0
        moon.attenuationStartDistance = 300.0
        moon.attenuationEndDistance = 700.0

        let moonNode = SCNNode()
        moonNode.light = moon
        moonNode.position = SCNVector3Make(-5.0, 450.0, 5.0)
        moonNode.constraints = [SCNLookAtConstraint(target: terrainNode)]

        let sunOrbitNode = SCNNode()
        sunOrbitNode.addChildNode(sunNode)
        sunOrbitNode.rotation = SCNVector4Make(0.5, 1.0, 1.0, 0.0)

        let moonOrbitNode = SCNNode()
        moonOrbitNode.addChildNode(moonNode)
        moonOrbitNode.rotation = SCNVector4Make(0.3, 0.7, 0.9, 0.0)

        let sunOrbitDuration = 600.0
        let moonOrbitDuration = 27.322 * sunOrbitDuration

        let sunOrbit = CABasicAnimation(keyPath: "rotation.w")
        sunOrbit.byValue = Float.pi * -2.0
        sunOrbit.duration = sunOrbitDuration
        sunOrbit.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        sunOrbit.repeatCount = Float.infinity
        sunOrbitNode.addAnimation(sunOrbit, forKey: "move sun in orbit")

        let moonOrbit = CABasicAnimation(keyPath: "rotation.w")
        moonOrbit.byValue = Float.pi * -2.0
        moonOrbit.duration = moonOrbitDuration
        moonOrbit.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        moonOrbit.repeatCount = Float.infinity
        moonOrbitNode.addAnimation(moonOrbit, forKey: "move moon in orbit")

        scene.rootNode.addChildNode(sunOrbitNode)
        scene.rootNode.addChildNode(moonOrbitNode)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }

    private func createTerrain(in scene: SCNScene) {
        let tg = TerrainGenerator(width: 32, depth: 25)
        let grid = tg.generate(level: terrainIndex)
        let nodeFactory = NodeFactory(sideLength: 10.0)

        terrainNode = nodeFactory.createTerrainNode(grid: grid)
        terrainNode.position = SCNVector3Make(0, 0, 0)
        scene.rootNode.addChildNode(terrainNode)

        if let sentinelPosition = tg.sentinelPosition, let sentinelPiece = grid.get(point: sentinelPosition) {
            let sentinelNode = nodeFactory.createSentinelNode(grid: grid, piece: sentinelPiece)
            terrainNode.addChildNode(sentinelNode)
        }

        for guardianPosition in tg.guardianPositions {
            if let guardianPiece = grid.get(point: guardianPosition) {
                let guardianNode = nodeFactory.createGuardianNode(grid: grid, piece: guardianPiece)
                terrainNode.addChildNode(guardianNode)
            }
        }

        terrainIndex += 1
    }

    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        guard
            let sceneView = self.view as? SCNView,
            let scene = sceneView.scene
        else {
            return
        }

        terrainNode.removeFromParentNode()

        createTerrain(in: scene)
    }
}
