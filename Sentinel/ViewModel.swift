import SceneKit

fileprivate let undefinedPosition = GridPoint(x: -1, z: -1)

class ViewModel: NSObject, SCNSceneRendererDelegate {
    let terrainIndex: Int
    let scene: SCNScene
    let grid: Grid
    let nodeFactory: NodeFactory
    let nodeMap: NodeMap

    private var currentPosition = undefinedPosition
    private var currentAngle: Float = 0.0

    private var playerNode: SCNNode?
    private var oppositionCameraNodes: [SCNNode] = []

    var preAnimationBlock: (() -> Void)?
    var postAnimationBlock: (() -> Void)?

    init(terrainIndex: Int) {
        self.terrainIndex = terrainIndex

        self.scene = SCNScene()

        let tg = TerrainGenerator()
        self.grid = tg.generate(level: terrainIndex,
                                maxLevel: 99,
                                minWidth: 24,
                                maxWidth: 32,
                                minDepth: 16,
                                maxDepth: 24)

        let nodePositioning = NodePositioning(gridWidth: Float(grid.width),
                                              gridDepth: Float(grid.depth),
                                              sideLength: 10.0)

        self.nodeFactory = NodeFactory(nodePositioning: nodePositioning)
        self.nodeMap = NodeMap()

        super.init()

        setupScene()
    }

    private func setupScene() {
        let skyBox = SkyBox(sourceImage: #imageLiteral(resourceName: "skybox.png"))
        if let components = skyBox.componentImages() {
            scene.background.contents = components
        }

        let terrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: nodeMap)
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
        orbitNode.name = "orbitNodeName"
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

        playerNode = terrainNode.childNode(withName: playerNodeName, recursively: true)
        let oppositionNodeNames = [sentinelNodeName, guardianNodeName]
        let oppositionNodes = terrainNode.childNodes(passingTest: { (node, stop) -> Bool in
            if let name = node.name {
                return oppositionNodeNames.contains(name)
            }
            return false
        })

        for oppositionNode in oppositionNodes {
            if let cameraNode = oppositionNode.childNode(withName: cameraNodeName, recursively: true) {
                oppositionCameraNodes.append(cameraNode)
            }
        }
    }

    func process(hitTestResults: [SCNHitTestResult]) {
        if hasEnteredScene() {
            if hitTestResults.count > 0 {
                let node = hitTestResults[0].node
                if let piece = nodeMap.getPiece(for: node) {
                    let angle = piece.point.angle(to: currentPosition)
                    moveCamera(to: piece, facing: angle, animationDuration: 1.0)
                }
            }
        } else {
            enterScene()
        }
    }

    func processPan(by x: Float, finished: Bool) {
        guard
            let cameraNode = scene.rootNode.childNode(withName: cameraNodeName, recursively: true)
            else  {
                return
        }

        let position = cameraNode.position
        let angleDeltaDegrees = x / 10.0
        let angleDeltaRadians = angleDeltaDegrees * Float.pi / 180.0
        var newRadians = currentAngle + angleDeltaRadians

        cameraNode.transform = SCNMatrix4MakeRotation(newRadians, 0, 1, 0)
        cameraNode.position = position

        if finished {
            while newRadians < 0 {
                newRadians += (2.0 * Float.pi)
            }
            currentAngle = newRadians
        }
    }

    private func hasEnteredScene() -> Bool {
        return currentPosition != undefinedPosition
    }

    private func enterScene() {
        if let startPiece = grid.get(point: grid.startPosition) {
            let angleToSentinel = grid.startPosition.angle(to: grid.sentinelPosition)
            moveCamera(to: startPiece, facing: angleToSentinel, animationDuration: 3.0)
        }
    }

    private func moveCamera(to piece:GridPiece, facing: Float, animationDuration: CFTimeInterval) {
        guard
            let cameraNode = scene.rootNode.childNode(withName: cameraNodeName, recursively: true)
            else  {
                return
        }

        let point = piece.point
        let nodePositioning = nodeFactory.nodePositioning
        let newPosition = nodePositioning.calculatePosition(x: point.x, y: Int(piece.level + 1.0), z: point.z)

        if let preAnimationBlock = preAnimationBlock {
            preAnimationBlock()
        }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = animationDuration
        SCNTransaction.completionBlock = {
            if let postAnimationBlock = self.postAnimationBlock {
                postAnimationBlock()
            }
        }

        cameraNode.constraints = nil
        cameraNode.transform = SCNMatrix4MakeRotation(facing, 0, 1, 0)
        cameraNode.position = newPosition

        SCNTransaction.commit()

        currentAngle = facing
        currentPosition = point
    }

    // MARK: SCNSceneRendererDelegate

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let playerNode = playerNode else {
            return
        }

        let playerPresentationNode = playerNode.presentation

        for cameraNode in oppositionCameraNodes {
            let cameraPresentationNode = cameraNode.presentation
            if can(camera: cameraPresentationNode, see: playerPresentationNode, renderer: renderer) {
                print("SEEN")
            }
        }
    }

    private func can(camera: SCNNode, see player: SCNNode, renderer: SCNSceneRenderer) -> Bool {
        return renderer.isNode(player, insideFrustumOf: camera)
    }
}
