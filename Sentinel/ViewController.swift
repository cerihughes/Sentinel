import SceneKit

class ViewController: UIViewController {
    let viewModel: ViewModel

    var tapRecogniser: UITapGestureRecognizer?
    var panRecogniser: UIPanGestureRecognizer?

    var currentPosition = GridPoint(x: 0, z: 0)
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

        let nodeFactory = viewModel.nodeFactory
        let scene = SCNScene()
        sceneView.scene = scene

        let skyBox = SkyBox(sourceImage: #imageLiteral(resourceName: "skybox.png"))
        if let components = skyBox.componentImages() {
            scene.background.contents = components
        }

        let terrainNode = nodeFactory.createTerrainNode(grid: viewModel.grid)
        terrainNode.position = SCNVector3Make(0, 0, 0)

        let cameraNode = nodeFactory.createCameraNode()
        cameraNode.position = SCNVector3Make(25.0, 200.0, 225.0)
        let lookAt = SCNLookAtConstraint(target: terrainNode)
        cameraNode.constraints = [lookAt]

        let ambientLightNodes = nodeFactory.createAmbientLightNodes(distance: 200.0)
        let sunNode = nodeFactory.createSunNode()
        sunNode.position = SCNVector3Make(-500.0, 275.0, -250.0)
        sunNode.constraints = [SCNLookAtConstraint(target: terrainNode)]

        let orbitNode = SCNNode()
        orbitNode.rotation = SCNVector4Make(0.38, 0.42, 0.63, 0.0)
        let orbit = CABasicAnimation(keyPath: "rotation.w")
        orbit.byValue = Float.pi * -2.0
        orbit.duration = 100.0
        orbit.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        orbit.repeatCount = Float.infinity
        orbitNode.addAnimation(orbit, forKey: "orbit")

        orbitNode.addChildNode(cameraNode)
        orbitNode.addChildNode(terrainNode)
        for ambientLightNode in ambientLightNodes {
            orbitNode.addChildNode(ambientLightNode)
        }

        scene.rootNode.addChildNode(orbitNode)
        scene.rootNode.addChildNode(sunNode)

        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        sceneView.addGestureRecognizer(tapRecogniser)

        let panRecogniser = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
        panRecogniser.isEnabled = false
        sceneView.addGestureRecognizer(panRecogniser)

        self.tapRecogniser = tapRecogniser
        self.panRecogniser = panRecogniser
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

        if let panRecogniser = panRecogniser, !panRecogniser.isEnabled {
            let grid = viewModel.grid
            if let startPiece = grid.get(point: grid.startPosition) {
                let angleToSentinel = grid.startPosition.angle(to: grid.sentinelPosition)
                moveCamera(to: startPiece, facing: angleToSentinel, scene: scene, animationDuration: 3.0)
            }
            return
        }

        let point = gestureRecognizer.location(in: sceneView)
        let options: [SCNHitTestOption:SCNNode] = [.rootNode:terrainNode]
        let hitResults = sceneView.hitTest(point, options: options)

        if hitResults.count > 0 {
            let node = hitResults[0].node
            if let piece = nodeMap.getPiece(for: node) {
                let angle = piece.point.angle(to: currentPosition)
                moveCamera(to: piece, facing: angle, scene: scene)
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
        var newRadians = currentAngle + angleDeltaRadians

        cameraNode.transform = SCNMatrix4MakeRotation(newRadians, 0, 1, 0)
        cameraNode.position = position

        if sender.state == .ended {
            while newRadians < 0 {
                newRadians += (2.0 * Float.pi)
            }
            currentAngle = newRadians
        }
    }

    private func moveCamera(to piece:GridPiece, facing: Float, scene: SCNScene, animationDuration: CFTimeInterval = 1.0) {
        guard
            let cameraNode = scene.rootNode.childNode(withName: cameraNodeName, recursively: true)
             else  {
                return
        }

        let point = piece.point
        let nodePositioning = viewModel.nodeFactory.nodePositioning
        let newPosition = nodePositioning.calculatePosition(x: point.x, y: Int(piece.level + 1.0), z: point.z)

        tapRecogniser?.isEnabled = false
        panRecogniser?.isEnabled = false

        SCNTransaction.begin()
        SCNTransaction.animationDuration = animationDuration
        SCNTransaction.completionBlock = {
            self.tapRecogniser?.isEnabled = true
            self.panRecogniser?.isEnabled = true
        }

        cameraNode.constraints = nil
        cameraNode.transform = SCNMatrix4MakeRotation(facing, 0, 1, 0)
        cameraNode.position = newPosition

        self.currentAngle = facing
        self.currentPosition = point

        SCNTransaction.commit()
    }
}
