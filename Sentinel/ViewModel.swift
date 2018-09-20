import SceneKit

enum UserInteraction {
    case tap, longPress
}

let treeEnergyValue = 1
let rockEnergyValue = 2
let synthoidEnergyValue = 3
let sentryEnergyValue = 3
let sentinelEnergyValue = 4

protocol ViewModelDelegate: class {
    func viewModel(_: ViewModel, didChange cameraNode: SCNNode)
}

class ViewModel: NSObject, SCNSceneRendererDelegate {
    let levelConfiguration: LevelConfiguration
    let world: World
    weak var delegate: ViewModelDelegate?
    var preAnimationBlock: (() -> Void)?
    var postAnimationBlock: (() -> Void)?

    private let grid: Grid
    private let nodeFactory: NodeFactory
    private let nodeMap: NodeMap
    private let timeEngine = TimeEngine()
    private var energy: Int = 10
    private let terrainNode: TerrainNode

    init(levelConfiguration: LevelConfiguration, nodeFactory: NodeFactory, world: World) {
        self.levelConfiguration = levelConfiguration
        self.world = world

        let tg = TerrainGenerator()
        self.grid = tg.generate(levelConfiguration: levelConfiguration)
        self.nodeFactory = nodeFactory
        self.nodeMap = NodeMap()
        self.terrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: nodeMap)
        world.set(terrainNode: self.terrainNode)

        super.init()

        setupTimingFunctions()
    }

    private func setupTimingFunctions() {
        _ = timeEngine.add(timeInterval: 2.0) { (timeInterval, renderer) -> Bool in
            self.oppositionScan(in: renderer)
            return true
        }

        let radians = 2.0 * Float.pi / Float(levelConfiguration.opponentRotationSteps)
        let duration = levelConfiguration.opponentRotationTime
        _ = timeEngine.add(timeInterval: levelConfiguration.opponentRotationPause) { (timeInterval, renderer) -> Bool in
            for oppositionNode in self.terrainNode.oppositionNodes {
                oppositionNode.rotate(by: radians, duration: duration)
            }
            return true
        }
    }

    func cameraNode(for viewer: Viewer) -> SCNNode? {
        if let viewingNode = viewingNode(for: viewer) {
            return viewingNode.cameraNode
        }
        return nil
    }

    private func viewingNode(for viewer: Viewer) -> ViewingNode? {
        switch viewer {
        case .player:
            guard
                let currentFloorNode = nodeMap.getFloorNode(for: grid.currentPosition),
                let synthoidNode = currentFloorNode.synthoidNode
                else {
                    return nil
            }
            return synthoidNode
        case .sentinel:
            guard let sentinelNode = terrainNode.sentinelNode else {
                return nil
            }
            return sentinelNode
        default:
            let rawValueOffset = Viewer.sentry1.rawValue
            let index = viewer.rawValue - rawValueOffset
            if index < terrainNode.sentryNodes.count {
                return terrainNode.sentryNodes[index]
            }
            return nil
        }
    }

    func process(interaction: UserInteraction, hitTestResults: [SCNHitTestResult]) -> Bool {
        if hasEnteredScene() {
            if let hitTestResult = hitTestResults.first {
                let node = hitTestResult.node
                if let interactiveNode = node.firstInteractiveParent() {
                    return process(interaction: interaction, node: interactiveNode)
                }
            }
        } else {
            return enterScene()
        }
        return false
    }

    func processPan(by x: Float, finished: Bool) {
        guard
            let currentFloorNode = nodeMap.getFloorNode(for: grid.currentPosition),
            let synthoidNode = currentFloorNode.synthoidNode
            else {
                return
        }

        let currentAngle = synthoidNode.viewingAngle
        let angleDeltaDegrees = x / 10.0
        let angleDeltaRadians = angleDeltaDegrees * Float.pi / 180.0
        synthoidNode.apply(rotationDelta: angleDeltaRadians)

        if finished {
            var newRadians = currentAngle + angleDeltaRadians
            while newRadians < 0 {
                newRadians += (2.0 * Float.pi)
            }
            synthoidNode.viewingAngle = newRadians
        }
    }

    private func hasEnteredScene() -> Bool {
        return grid.currentPosition != undefinedPosition
    }

    private func enterScene() -> Bool {
        if let floorNode = nodeMap.getFloorNode(for: grid.startPosition),
            let synthoidNode = floorNode.synthoidNode {
            moveCamera(from: world.initialCameraNode,
                       to: synthoidNode.cameraNode,
                       animationDuration: 3.0)
            grid.currentPosition = grid.startPosition
            return true
        }
        return false
    }

    private func process(interaction: UserInteraction, node: SCNNode) -> Bool {
        let bitmask = node.categoryBitMask
        for interactiveNodeType in interactiveNodeType.allCases {
            if bitmask & interactiveNodeType.rawValue == interactiveNodeType.rawValue {
                return process(interaction: interaction, node: node, interactiveNodeType: interactiveNodeType)
            }
        }
        print("Not processing \(interaction) on \(bitmask)")
        return false
    }

    private func process(interaction: UserInteraction, node: SCNNode, interactiveNodeType: interactiveNodeType) -> Bool {
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
                return processTapFloor(node: node, piece: piece)
            }
        case (.tap, .synthoid):
            if let synthoidNode = node as? SynthoidNode {
                move(to: synthoidNode)
                return true
            }
        case (.longPress, .floor):
            if let piece = piece {
                return processLongPressFloor(node: node, piece: piece)
            }
        case (.longPress, _):
            if let piece = piece {
                return processLongPressObject(node: node, piece: piece, interactiveNodeType: interactiveNodeType)
            }
        default:
            print("Not processing \(interactiveNodeType)")
        }
        return false
    }

    private func processTapFloor(node: SCNNode, piece: GridPiece) -> Bool {
        let point = piece.point

        if grid.sentinelPosition == point || grid.sentryPositions.contains(point) {
            return false
        } else if grid.treePositions.contains(point) {
            buildRock(at: piece)
        } else if grid.rockPositions.contains(point) && !grid.synthoidPositions.contains(point) {
            buildRock(at: piece)
        } else if grid.synthoidPositions.contains(point) {
            if let floorNode = node as? FloorNode,
                let synthoidNode = floorNode.synthoidNode {
                move(to: synthoidNode)
            }
        } else {
            // Empty space - build a rock
            buildRock(at: piece)
        }
        return true
    }

    private func processLongPressFloor(node: SCNNode, piece: GridPiece) -> Bool {
        let point = piece.point

        guard grid.sentinelPosition != point,
            !grid.sentryPositions.contains(point),
            !grid.treePositions.contains(point),
            !grid.synthoidPositions.contains(point) else {
                return false
        }

        let viewingAngle = point.angle(to: grid.currentPosition)
        buildSynthoid(at: piece, viewingAngle: viewingAngle)
        return true
    }

    private func processLongPressObject(node: SCNNode, piece: GridPiece, interactiveNodeType: interactiveNodeType) -> Bool {
        let point = piece.point

        if grid.sentinelPosition == point && interactiveNodeType == .sentinel {
            // Absorb
        } else if grid.sentryPositions.contains(point) && interactiveNodeType == .sentry {
            // Absorb
        } else if grid.treePositions.contains(point) && interactiveNodeType == .tree {
            if let treeNode = node as? TreeNode {
                absorb(treeNode: treeNode, piece: piece)
                return true
            }
        } else if grid.rockPositions.contains(point) && interactiveNodeType == .rock {
            if let rockNode = node as? RockNode {
                absorb(rockNode: rockNode, piece: piece)
                return true
            }
        } else if grid.synthoidPositions.contains(point) && interactiveNodeType == .synthoid {
            absorb(synthoidNode: node, piece: piece)
            return true
        }
        return false
    }

    private func move(to synthoidNode: SynthoidNode) {
        guard
            let floorNode = synthoidNode.floorNode,
            let piece = nodeMap.getPiece(for: floorNode)
            else {
                return
        }
        let point = piece.point
        moveCamera(to: synthoidNode, animationDuration: 1.0)
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

        let treeNode = nodeFactory.createTreeNode(height: piece.rockCount)
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

        let rockNode = nodeFactory.createRockNode(height: startRockCount)
        floorNode.add(rockNode: rockNode)

        adjustEnergy(delta: -rockEnergyValue, isPlayer: isPlayer)
    }

    private func buildSynthoid(at piece: GridPiece, viewingAngle: Float) {
        guard hasEnergy(required: synthoidEnergyValue, isPlayer: true),
            let floorNode = nodeMap.getFloorNode(for: piece.point) else {
            return
        }

        let point = piece.point
        grid.synthoidPositions.append(point)

        let synthoidNode = nodeFactory.createSynthoidNode(height: piece.rockCount, viewingAngle: viewingAngle)
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

        if let randomPiece = emptyPieces.randomElement() {
            buildTree(at: randomPiece, isPlayer: false)
        }
    }

    private func moveCamera(to nextSynthoidNode: SynthoidNode, animationDuration: CFTimeInterval) {
        guard
            let currentFloorNode = nodeMap.getFloorNode(for: grid.currentPosition),
            let currentSynthoidNode = currentFloorNode.synthoidNode
            else {
                return
        }

        moveCamera(from: currentSynthoidNode.cameraNode,
                   to: nextSynthoidNode.cameraNode,
                   animationDuration: animationDuration)
    }

    private func moveCamera(from: SCNNode, to: SCNNode, animationDuration: CFTimeInterval) {
        guard
            let delegate = delegate,
            let parent = from.parent
            else {
                return
        }

        if let preAnimationBlock = preAnimationBlock {
            preAnimationBlock()
        }

        let transitionCameraNode = from.clone()
        parent.addChildNode(transitionCameraNode)
        delegate.viewModel(self, didChange: transitionCameraNode)

        SCNTransaction.begin()
        SCNTransaction.animationDuration = animationDuration
        SCNTransaction.completionBlock = {
            delegate.viewModel(self, didChange: to)
            transitionCameraNode.removeFromParentNode()
            if let postAnimationBlock = self.postAnimationBlock {
                postAnimationBlock()
            }
        }

        transitionCameraNode.setWorldTransform(to.worldTransform)

        SCNTransaction.commit()
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
            if let visibleSynthoid = oppositionNode.visibleSynthoids(in: renderer).randomElement() {
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
            } else if let visibleRock = oppositionNode.visibleRocks(in: renderer).randomElement(),
                let floorNode = visibleRock.floorNode,
                let piece = nodeMap.getPiece(for: floorNode) {
                absorb(rockNode: visibleRock, piece: piece, isPlayer: false)
                buildTree(at: piece, isPlayer: false)
                oppositionBuildRandomTree()
            } else if let visibleTree = oppositionNode.visibleTreesOnRocks(in: renderer).randomElement(),
                let floorNode = visibleTree.floorNode,
                let piece = nodeMap.getPiece(for: floorNode) {
                absorb(treeNode: visibleTree, piece: piece, isPlayer: false)
                oppositionBuildRandomTree()
            }
        }
    }
}
