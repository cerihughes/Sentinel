import SceneKit

enum UserInteraction {
    case tap, longPress
}

let treeEnergyValue = 1
let rockEnergyValue = 2
let synthoidEnergyValue = 3
let sentryEnergyValue = 3
let sentinelEnergyValue = 4

class ViewModel: NSObject, SCNSceneRendererDelegate {
    let scene: SCNScene
    var preAnimationBlock: (() -> Void)?
    var postAnimationBlock: (() -> Void)?

    private let levelConfiguration: LevelConfiguration
    private let grid: Grid
    private let nodeFactory: NodeFactory
    private let nodeMap: NodeMap
    private let timeEngine = TimeEngine()
    private var currentAngle: Float = 0.0
    private var energy: Int = 10
    private var terrainNode: TerrainNode

    init(levelConfiguration: LevelConfiguration) {
        self.levelConfiguration = levelConfiguration

        self.scene = SCNScene()

        let tg = TerrainGenerator()
        self.grid = tg.generate(levelConfiguration: levelConfiguration)

        let nodePositioning = NodePositioning(gridWidth: Float(grid.width),
                                              gridDepth: Float(grid.depth),
                                              floorSize: 10.0)

        self.nodeFactory = NodeFactory(nodePositioning: nodePositioning)
        self.nodeMap = NodeMap()
        self.terrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: nodeMap)

        super.init()

        setupScene()
        setupTimingFunctions()
    }

    private func setupScene() {
        let skyBox = SkyBox(sourceImage: #imageLiteral(resourceName: "skybox.png"))
        if let components = skyBox.componentImages() {
            scene.background.contents = components
        }

        let cameraNode = nodeFactory.createCameraNode()
        cameraNode.position = SCNVector3Make(25.0, 200.0, 225.0)
        let lookAt = SCNLookAtConstraint(target: terrainNode)
        cameraNode.constraints = [lookAt]

        let ambientLightNodes = nodeFactory.createAmbientLightNodes(distance: 200.0)
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
    }

    private func setupTimingFunctions() {
        _ = timeEngine.add(timeInterval: 2.0) { (timeInterval, renderer) -> Bool in
            self.oppositionScan(in: renderer)
            return true
        }

        let radians = 2.0 * Float.pi / Float(levelConfiguration.rotationSteps)
        let duration = levelConfiguration.rotationTime
        _ = timeEngine.add(timeInterval: levelConfiguration.rotationPause) { (timeInterval, renderer) -> Bool in
            for oppositionNode in self.terrainNode.oppositionNodes {
                oppositionNode.rotate(by: radians, duration: duration)
            }
            return true
        }
    }

    func cameraNode(for viewer: Viewer) -> SCNNode? {
        switch viewer {
        case .player:
            return scene.rootNode.childNode(withName: cameraNodeName, recursively: true)
        case .sentinel:
            guard let sentinelNode = terrainNode.sentinelNode else {
                return nil
            }
            return sentinelNode.cameraNode
        default:
            return nil
        }
    }

    func process(interaction: UserInteraction, hitTestResults: [SCNHitTestResult]) {
        if hasEnteredScene() {
            if let hitTestResult = hitTestResults.first {
                let node = hitTestResult.node
                if let interactiveNode = node.firstInteractiveParent() {
                    process(interaction: interaction, node: interactiveNode)
                    return
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
        for interactiveNodeType in interactiveNodeType.allValues() {
            if bitmask & interactiveNodeType.rawValue == interactiveNodeType.rawValue {
                process(interaction: interaction, node: node, interactiveNodeType: interactiveNodeType)
                return
            }
        }
        print("Not processing \(interaction) on \(bitmask)")
    }

    private func process(interaction: UserInteraction, node: SCNNode, interactiveNodeType: interactiveNodeType) {
        var piece: GridPiece? = nil
        if let floorNode = node as? FloorNode {
            piece = nodeMap.getPiece(for: floorNode)
        } else if let floorNode = node.parent as? FloorNode,
            let floorName = floorNode.name,
            floorName == floorNodeName {
            piece = nodeMap.getPiece(for: floorNode)
        }

        switch (interaction, interactiveNodeType) {
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
                processLongPressObject(node: node, piece: piece, interactiveNodeType: interactiveNodeType)
            }
        default:
            print("Not processing \(interactiveNodeType)")
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

    private func processLongPressObject(node: SCNNode, piece: GridPiece, interactiveNodeType: interactiveNodeType) {
        let point = piece.point

        if grid.sentinelPosition == point && interactiveNodeType == .sentinel {
            // Absorb
        } else if grid.sentryPositions.contains(point) && interactiveNodeType == .sentry {
            // Absorb
        } else if grid.treePositions.contains(point) && interactiveNodeType == .tree {
            if let treeNode = node as? TreeNode {
                absorb(treeNode: treeNode, piece: piece)
            }
        } else if grid.rockPositions.contains(point) && interactiveNodeType == .rock {
            if let rockNode = node as? RockNode {
                absorb(rockNode: rockNode, piece: piece)
            }
        } else if grid.synthoidPositions.contains(point) && interactiveNodeType == .synthoid {
            absorb(synthoidNode: node, piece: piece)
        }
    }

    private func move(to piece: GridPiece) {
        let point = piece.point
        let angle = point.angle(to: grid.currentPosition)
        moveCamera(to: piece, facing: angle, animationDuration: 1.0)
        grid.currentPosition = point
    }

    private func hasEnergy(required: Int, isPlayer: Bool) -> Bool {
        if !isPlayer {
            return true
        }

        return energy > required
    }

    private func adjustEnergy(delta: Int, isPlayer: Bool) {
        guard isPlayer else {
            return
        }

        energy += delta
    }

    private func buildTree(at piece: GridPiece, isPlayer: Bool = true) {
        guard hasEnergy(required: treeEnergyValue, isPlayer: isPlayer),
            let floorNode = nodeMap.getFloorNode(for: piece.point) else {
            return
        }

        let point = piece.point
        grid.treePositions.append(point)

        let treeNode = nodeFactory.createTreeNode(rockCount: piece.rockCount)
        floorNode.treeNode = treeNode

        adjustEnergy(delta: -treeEnergyValue, isPlayer: isPlayer)
    }

    private func buildRock(at piece: GridPiece, isPlayer: Bool = true) {
        guard hasEnergy(required: treeEnergyValue, isPlayer: isPlayer),
            let floorNode = nodeMap.getFloorNode(for: piece.point) else {
            return
        }

        let point = piece.point
        if (grid.treePositions.contains(point)) {
            if let treeNode = floorNode.treeNode {
                absorb(treeNode: treeNode, piece: piece)
            }
        }

        guard hasEnergy(required: rockEnergyValue, isPlayer: isPlayer) else {
            return
        }

        let startRockCount = piece.rockCount
        if piece.rockCount == 0 {
            grid.rockPositions.append(point)
        }

        piece.rockCount += 1

        let rockNode = nodeFactory.createRockNode(rockCount: startRockCount)
        floorNode.add(rockNode: rockNode)

        adjustEnergy(delta: -rockEnergyValue, isPlayer: isPlayer)
    }

    private func buildSynthoid(at piece: GridPiece) {
        guard hasEnergy(required: synthoidEnergyValue, isPlayer: true),
            let floorNode = nodeMap.getFloorNode(for: piece.point) else {
            return
        }

        let point = piece.point
        grid.synthoidPositions.append(point)

        let synthoidNode = nodeFactory.createSynthoidNode(rockCount: piece.rockCount)
        floorNode.synthoidNode = synthoidNode

        adjustEnergy(delta: -synthoidEnergyValue, isPlayer: true)
    }

    private func absorb(treeNode: TreeNode, piece: GridPiece, isPlayer: Bool = true) {
        let point = piece.point
        guard let index = grid.treePositions.index(of: point) else {
            return
        }

        treeNode.removeFromParentNode()
        grid.treePositions.remove(at: index)

        adjustEnergy(delta: treeEnergyValue, isPlayer: isPlayer)
    }

    private func absorb(rockNode: RockNode, piece: GridPiece, isPlayer: Bool = true) {
        let point = piece.point
        guard let floorNode = nodeMap.getFloorNode(for: piece.point) else {
            return
        }

        // TODO: Tidy this up - can use topmost now?
        if grid.synthoidPositions.contains(point) {
            if let synthoidNode = floorNode.synthoidNode {
                absorb(synthoidNode: synthoidNode, piece: piece, isPlayer: isPlayer)
            }
        } else if grid.treePositions.contains(point) {
            if let treeNode = floorNode.treeNode {
                absorb(treeNode: treeNode, piece: piece, isPlayer: isPlayer)
            }
        }

        var absorbedRockNode: RockNode?
        repeat {
            absorbedRockNode = floorNode.removeLastRockNode()
            if absorbedRockNode != nil {
                adjustEnergy(delta: rockEnergyValue, isPlayer: isPlayer)
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

    private func absorb(synthoidNode: SCNNode, piece: GridPiece, isPlayer: Bool = true) {
        let point = piece.point
        guard let index = grid.synthoidPositions.index(of: point) else {
            return
        }

        synthoidNode.removeFromParentNode()
        grid.synthoidPositions.remove(at: index)

        adjustEnergy(delta: synthoidEnergyValue, isPlayer: isPlayer)
    }

    private func oppositionBuildRandomTree() {
        let gridIndex = GridIndex(grid: grid)
        let emptyPieces = gridIndex.allPieces()

        guard emptyPieces.count > 0 else {
            return
        }

        // TODO: Replace when Swift 4.2 is out of beta
        let randomIndex = Int(arc4random_uniform(UInt32(emptyPieces.count)))
        let randomPiece = emptyPieces[randomIndex]

        buildTree(at: randomPiece, isPlayer: false)
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
        timeEngine.handle(currentTimeInterval: time, renderer: renderer)
    }

    private func oppositionScan(in renderer: SCNSceneRenderer) {
        guard let floorNode = nodeMap.getFloorNode(for: grid.currentPosition),
            let synthoidNode = floorNode.synthoidNode else {
                return
        }

        for oppositionNode in terrainNode.oppositionNodes {
            if let visibleSynthoid = oppositionNode.visibleSynthoids(in: renderer).first { // Maybe random in Swift 4.2?
                if visibleSynthoid == synthoidNode {
                    print("SEEN")
                } else {
                    if let floorNode = visibleSynthoid.floorNode,
                        let piece = nodeMap.getPiece(for: floorNode) {
                        absorb(synthoidNode: visibleSynthoid, piece: piece, isPlayer: false)
                        buildRock(at: piece, isPlayer: false)
                        oppositionBuildRandomTree()
                    }
                }
            } else if let visibleRock = oppositionNode.visibleRocks(in: renderer).first, // Maybe random in Swift 4.2?
                let floorNode = visibleRock.floorNode,
                let piece = nodeMap.getPiece(for: floorNode) {
                absorb(rockNode: visibleRock, piece: piece, isPlayer: false)
                buildTree(at: piece, isPlayer: false)
                oppositionBuildRandomTree()
            } else if let visibleTree = oppositionNode.visibleTreesOnRocks(in: renderer).first, // Maybe random in Swift 4.2?
                let floorNode = visibleTree.floorNode,
                let piece = nodeMap.getPiece(for: floorNode) {
                absorb(treeNode: visibleTree, piece: piece, isPlayer: false)
                oppositionBuildRandomTree()
            }
        }
    }
}
