import SceneKit

class ViewController: UIViewController {
    let viewModel: ViewModel

    var currentAngle: Float = 0.0

    init(viewModel: ViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = SCNView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let sceneView = self.view as? SCNView else {
            return
        }

        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor(white: 0.7, alpha: 1.0)

        let scene = SCNScene()
        sceneView.scene = scene

        let terrainNode = createTerrain(in: scene)

        let cameraNode = viewModel.nodeFactory.createCameraNode()
        cameraNode.position = SCNVector3Make(25.0, 200.0, 225.0)
        let lookAt = SCNLookAtConstraint(target: terrainNode)
        lookAt.isGimbalLockEnabled = true
        cameraNode.constraints = [lookAt]
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

        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        sceneView.addGestureRecognizer(tapRecogniser)

        let panRecogniser = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
        sceneView.addGestureRecognizer(panRecogniser)
    }

    private func createTerrain(in scene: SCNScene) -> SCNNode {
        let nodeFactory = viewModel.nodeFactory
        let terrainNode = nodeFactory.createTerrainNode(grid: viewModel.grid)
        terrainNode.position = SCNVector3Make(0, 0, 0)
        scene.rootNode.addChildNode(terrainNode)
        return terrainNode
    }

    @objc
    func tapGesture(_ gestureRecognizer: UIGestureRecognizer) {
        let nodeFactory = viewModel.nodeFactory
        guard
            let sceneView = self.view as? SCNView,
            let scene = sceneView.scene,
            let terrainNode = scene.rootNode.childNode(withName: terrainNodeName, recursively: true),
            let nodeMap = nodeFactory.nodeMap else {
                return
        }

        let point = gestureRecognizer.location(in: sceneView)
        let options: [SCNHitTestOption:SCNNode] = [.rootNode:terrainNode]
        let hitResults = sceneView.hitTest(point, options: options)

        if hitResults.count > 0 {
            let node = hitResults[0].node
            if let piece = nodeMap.getPiece(for: node) {
                moveCamera(to: piece, scene: scene)
            }
        }
    }

    @objc
    func panGesture(sender: UIPanGestureRecognizer) {
        guard
            let sceneView = self.view as? SCNView,
            let scene = sceneView.scene,
            let cameraNode = scene.rootNode.childNode(withName: cameraNodeName, recursively: true)
            else  {
                return
        }

        let position = cameraNode.position
        let translation = sender.translation(in: sender.view!)
        let angleDeltaDegrees = Float(translation.x) / 10.0
        let angleDeltaRadians = angleDeltaDegrees * Float.pi / 180.0
        let newRadians = currentAngle + angleDeltaRadians
        print("Δx: \(translation.x) Δ degrees: \(angleDeltaDegrees) Δ radians: \(angleDeltaRadians) radians: \(newRadians)")

        cameraNode.constraints = nil
        cameraNode.transform = SCNMatrix4MakeRotation(newRadians, 0, 1, 0)
        cameraNode.position = position

        if sender.state == .ended {
            currentAngle = newRadians
        }
    }

    private func moveCamera(to piece:GridPiece, scene: SCNScene, animationDuration: CFTimeInterval = 1.0, lookAt: SCNNode? = nil) {
        guard
            let cameraNode = scene.rootNode.childNode(withName: cameraNodeName, recursively: true)
             else  {
                return
        }

        let point = piece.point
        let nodePositioning = viewModel.nodeFactory.nodePositioning
        let newPosition = nodePositioning.calculatePosition(x: point.x, y: piece.level + 1.0, z: point.z)

        SCNTransaction.begin()
        SCNTransaction.animationDuration = animationDuration

        let constraint = SCNLookAtConstraint(target: lookAt)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]
        cameraNode.position = newPosition

        SCNTransaction.commit()
    }
}
