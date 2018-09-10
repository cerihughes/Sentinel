import SceneKit

enum UserInteraction {
    case tap, longPress
}

class ViewModel: NSObject, SCNSceneRendererDelegate {
    let terrainIndex: Int
    let scene: SCNScene
    let grid: Grid
    let nodeFactory: NodeFactory
    let nodeMap: NodeMap

    private var currentAngle: Float = 0.0

    private var terrainNode: SCNNode?
    private var synthoidNode: SCNNode?
    private var oppositionCameraNodes: [SCNNode] = []

    var preAnimationBlock: (() -> Void)?
    var postAnimationBlock: (() -> Void)?

    init(terrainIndex: Int) {
        self.terrainIndex = terrainIndex

        self.scene = SCNScene()

        let configuration = LevelConfiguration(level: terrainIndex)
        let tg = TerrainGenerator()
        self.grid = tg.generate(levelConfiguration: configuration)

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
        self.terrainNode = terrainNode

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

        synthoidNode = terrainNode.childNode(withName: synthoidNodeName, recursively: true)
        let oppositionNodeNames = [sentinelNodeName, sentryNodeName]
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

    func process(interaction: UserInteraction, hitTestResults: [SCNHitTestResult]) {
        if hasEnteredScene() {
            if let hitTestResult = hitTestResults.first {
                let node = hitTestResult.node
                if let interactableNode = firstInteractableParent(of: node) {
                    process(interaction: interaction, node: interactableNode)
                    return
                }
            }
        } else {
            enterScene()
        }
    }

    private func firstInteractableParent(of node: SCNNode) -> SCNNode? {
        var interactableNode = node
        while interactableNode.categoryBitMask < InteractableNodeType.floor.rawValue {
            let parent = interactableNode.parent
            if (parent != nil) {
                interactableNode = parent!
            } else {
                return nil
            }
        }
        return interactableNode
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
        return grid.currentPosition != undefinedPosition
    }

    private func enterScene() {
        if let startPiece = grid.get(point: grid.startPosition) {
            let angleToSentinel = grid.startPosition.angle(to: grid.sentinelPosition)
            moveCamera(to: startPiece, facing: angleToSentinel, animationDuration: 3.0)
        }
    }

    private func process(interaction: UserInteraction, node: SCNNode) {
        let bitmask = node.categoryBitMask
        for interactableNodeType in InteractableNodeType.allValues() {
            if bitmask & interactableNodeType.rawValue == interactableNodeType.rawValue {
                process(interaction: interaction, node: node, interactableNodeType: interactableNodeType)
                return
            }
        }
        print("Not processing \(interaction) on \(bitmask)")
    }

    private func process(interaction: UserInteraction, node: SCNNode, interactableNodeType: InteractableNodeType) {
        var piece: GridPiece? = nil
        if let nodeName = node.name {
            if nodeName == floorNodeName {
                piece = nodeMap.getPiece(for: node)
            } else {
                if let floorNode = node.parent,
                    let floorName = floorNode.name,
                    floorName == floorNodeName {
                    piece = nodeMap.getPiece(for: floorNode)
                }
            }
        }

        switch (interaction, interactableNodeType) {
        case (.tap, .floor):
            if let piece = piece {
                processTapFloor(node: node, piece: piece)
            }
        case (.tap, .synthoid):
            if let piece = piece {
                move(to: piece)
            }
        case (.longPress, .floor):
            if let piece = piece {
                processLongPressFloor(node: node, piece: piece)
            }
        case (.longPress, _):
            if let piece = piece {
                processLongPressObject(node: node, piece: piece, interactableNodeType: interactableNodeType)
            }
        default:
            print("Not processing \(interactableNodeType)")
        }
    }

    private func processTapFloor(node: SCNNode, piece: GridPiece) {
        let point = piece.point

        if grid.sentinelPosition == point || grid.sentryPositions.contains(point) {
            // No op
        } else if grid.treePositions.contains(point) {
            buildRock(at: piece)
        } else if grid.rockPositions.contains(point) && !grid.synthoidPositions.contains(point) {
            buildRock(at: piece)
        } else if grid.synthoidPositions.contains(point) {
            move(to: piece)
        } else {
            // Empty space - build a rock
            buildRock(at: piece)
        }
    }

    private func processLongPressFloor(node: SCNNode, piece: GridPiece) {
        let point = piece.point

        guard grid.sentinelPosition != point,
            !grid.sentryPositions.contains(point),
            !grid.treePositions.contains(point),
            !grid.synthoidPositions.contains(point) else {
                return
        }

        buildSynthoid(at: piece)
    }

    private func processLongPressObject(node: SCNNode, piece: GridPiece, interactableNodeType: InteractableNodeType) {
        let point = piece.point

        if grid.sentinelPosition == point && interactableNodeType == .sentinel {
            // Absorb
        } else if grid.sentryPositions.contains(point) && interactableNodeType == .sentry {
            // Absorb
        } else if grid.treePositions.contains(point) && interactableNodeType == .tree {
            absorb(treeNode: node, piece: piece)
        } else if grid.rockPositions.contains(point) && interactableNodeType == .rock {
            absorb(rockNode: node, piece: piece)
        } else if grid.synthoidPositions.contains(point) && interactableNodeType == .synthoid {
            absorb(synthoidNode: node, piece: piece)
        }
    }

    private func move(to piece: GridPiece) {
        let point = piece.point
        let angle = point.angle(to: grid.currentPosition)
        moveCamera(to: piece, facing: angle, animationDuration: 1.0)
        grid.currentPosition = point
    }

    private func buildTree(at piece: GridPiece) {
        guard let floorNode = nodeMap.getNode(for: piece.point) else {
            return
        }

        let point = piece.point
        grid.treePositions.append(point)

        let treeNode = nodeFactory.createTreeNode()
        floorNode.addChildNode(treeNode)
    }

    private func buildRock(at piece: GridPiece) {
        guard let floorNode = nodeMap.getNode(for: piece.point) else {
            return
        }

        let point = piece.point
        let startRockCount = piece.rockCount
        if piece.rockCount == 0 {
            grid.rockPositions.append(point)
        }

        piece.rockCount += 1

        if (grid.treePositions.contains(point)) {
            absorbTree(from: floorNode, piece: piece)
        }

        let rockNode = nodeFactory.createRockNode(index: startRockCount)
        floorNode.addChildNode(rockNode)
    }

    private func buildSynthoid(at piece: GridPiece) {
        guard let floorNode = nodeMap.getNode(for: piece.point) else {
            return
        }

        let point = piece.point
        grid.synthoidPositions.append(point)

        let synthoidNode = nodeFactory.createSynthoidNode(index: piece.rockCount)
        floorNode.addChildNode(synthoidNode)
    }

    private func absorbTree(from floorNode: SCNNode, piece: GridPiece) {
        let point = piece.point
        guard
            let index = grid.treePositions.index(of: point),
            let _ = floorNode.removeTreeNode()
            else {
                return
        }

        grid.treePositions.remove(at: index)
    }

    private func absorb(treeNode: SCNNode, piece: GridPiece) {
        let point = piece.point
        guard let index = grid.treePositions.index(of: point) else {
            return
        }

        treeNode.removeFromParentNode()
        grid.treePositions.remove(at: index)
    }

    private func absorb(rockNode: SCNNode, piece: GridPiece) {
        let point = piece.point
        guard let floorNode = nodeMap.getNode(for: piece.point) else {
            return
        }

        if grid.synthoidPositions.contains(point) {
            if let synthoidNode = floorNode.synthoidNode() {
                absorb(synthoidNode: synthoidNode, piece: piece)
            }
        }

        var absorbedRockNode: SCNNode?
        repeat {
            absorbedRockNode = floorNode.removeLastRockNode()
            if absorbedRockNode != nil {
                piece.rockCount -= 1
                if piece.rockCount == 0 {
                    if let index = grid.rockPositions.index(of: point) {
                        grid.rockPositions.remove(at: index)
                    }
                }
            }

            if absorbedRockNode == rockNode {
                absorbedRockNode = nil // so that we drop out
            }
        } while absorbedRockNode != nil
    }

    private func absorb(synthoidNode: SCNNode, piece: GridPiece) {
        let point = piece.point
        guard let index = grid.synthoidPositions.index(of: point) else {
            return
        }

        synthoidNode.removeFromParentNode()
        grid.synthoidPositions.remove(at: index)
    }

    private func moveCamera(to piece: GridPiece, facing: Float, animationDuration: CFTimeInterval) {
        guard
            let cameraNode = scene.rootNode.childNode(withName: cameraNodeName, recursively: true)
            else  {
                return
        }

        let point = piece.point
        let nodePositioning = nodeFactory.nodePositioning
        let height = piece.rockLevel + 0.25
        let newPosition = nodePositioning.calculateTerrainPosition(x: point.x, y: height, z: point.z)

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
        grid.currentPosition = point
    }

    // MARK: SCNSceneRendererDelegate

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let synthoidNode = synthoidNode else {
            return
        }

        let synthoidPresentationNode = synthoidNode.presentation

        for cameraNode in oppositionCameraNodes {
            let cameraPresentationNode = cameraNode.presentation
            if can(camera: cameraPresentationNode, see: synthoidPresentationNode, renderer: renderer) {
                print("SEEN")
            }
        }
    }

    private func can(camera: SCNNode, see synthoid: SCNNode, renderer: SCNSceneRenderer) -> Bool {
        return renderer.isNode(synthoid, insideFrustumOf: camera)
    }
}
