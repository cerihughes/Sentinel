import SceneKit
import SpriteKit

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
    func viewModel(_: ViewModel, didRemoveOpponent cameraNode: SCNNode)
}

class ViewModel: NSObject, SCNSceneRendererDelegate {
    let levelConfiguration: LevelConfiguration
    let overlay = SKScene()
    let world: World
    weak var delegate: ViewModelDelegate?
    var preAnimationBlock: (() -> Void)?
    var postAnimationBlock: (() -> Void)?

    private let grid: Grid
    private let timeEngine = TimeEngine()
    private var energy: Int = 10
    private let playerNodeManipulator: NodeManipulator
    private let opponentNodeManipulator: NodeManipulator

    init(levelConfiguration: LevelConfiguration, nodeFactory: NodeFactory, world: World) {
        self.levelConfiguration = levelConfiguration
        self.world = world

        let tg = TerrainGenerator()
        self.grid = tg.generate(levelConfiguration: levelConfiguration)

        let playerNodeMap = NodeMap()
        let playerTerrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: playerNodeMap)

        let opponentNodeMap = NodeMap()
        let opponentTerrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: opponentNodeMap)

        world.set(playerTerrainNode: playerTerrainNode, opponentTerrainNode: opponentTerrainNode)

        playerNodeManipulator = NodeManipulator(terrainNode: playerTerrainNode, nodeMap: playerNodeMap, nodeFactory: nodeFactory)
        opponentNodeManipulator = NodeManipulator(terrainNode: opponentTerrainNode, nodeMap: opponentNodeMap, nodeFactory: nodeFactory)

        super.init()

        setupTimingFunctions()
    }

    private func setupTimingFunctions() {
        _ = timeEngine.add(timeInterval: 2.0) { (timeInterval, playerRenderer) -> Bool in
            self.oppositionScan(in: playerRenderer)
            return true
        }

        let radians = 2.0 * Float.pi / Float(levelConfiguration.opponentRotationSteps)
        let duration = levelConfiguration.opponentRotationTime
        _ = timeEngine.add(timeInterval: levelConfiguration.opponentRotationPause) { (timeInterval, playerRenderer) -> Bool in
            self.playerNodeManipulator.rotateOpposition(by: radians, duration: duration)
            self.opponentNodeManipulator.rotateOpposition(by: radians, duration: duration)
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
            guard let synthoidNode = playerNodeManipulator.synthoidNode(at: grid.currentPosition) else {
                return nil
            }
            return synthoidNode
        case .sentinel:
            guard let sentinelNode = opponentNodeManipulator.terrainNode.sentinelNode else {
                return nil
            }
            return sentinelNode
        default:
            let sentryNodes = opponentNodeManipulator.terrainNode.sentryNodes
            let rawValueOffset = Viewer.sentry1.rawValue
            let index = viewer.rawValue - rawValueOffset
            if index < sentryNodes.count {
                return sentryNodes[index]
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
        guard let synthoidNode = playerNodeManipulator.synthoidNode(at: grid.currentPosition) else {
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
        guard let synthoidNode = playerNodeManipulator.synthoidNode(at: grid.startPosition) else {
            return false
        }

        moveCamera(from: world.initialCameraNode,
                   to: synthoidNode.cameraNode,
                   animationDuration: 3.0)
        grid.currentPosition = grid.startPosition
        return true
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
        var point: GridPoint? = nil
        if let floorNode = node as? FloorNode {
            point = playerNodeManipulator.point(for: floorNode)
        } else if let floorNode = node.parent as? FloorNode,
            let floorName = floorNode.name,
            floorName == floorNodeName {
            point = playerNodeManipulator.point(for: floorNode)
        }

        switch (interaction, interactiveNodeType) {
        case (.tap, .floor):
            if let point = point {
                return processTapFloor(node: node, point: point)
            }
        case (.tap, .synthoid):
            if let synthoidNode = node as? SynthoidNode {
                move(to: synthoidNode)
                return true
            }
        case (.longPress, .floor):
            if let point = point {
                return processLongPressFloor(node: node, point: point)
            }
        case (.longPress, _):
            if let point = point {
                return processLongPressObject(node: node, point: point, interactiveNodeType: interactiveNodeType)
            }
        default:
            print("Not processing \(interactiveNodeType)")
        }
        return false
    }

    private func processTapFloor(node: SCNNode, point: GridPoint) -> Bool {
        if grid.sentinelPosition == point || grid.sentryPositions.contains(point) {
            return false
        } else if grid.treePositions.contains(point) {
            buildRock(at: point)
        } else if grid.rockPositions.contains(point) && !grid.synthoidPositions.contains(point) {
            buildRock(at: point)
        } else if grid.synthoidPositions.contains(point) {
            if let floorNode = node as? FloorNode,
                let synthoidNode = floorNode.synthoidNode {
                move(to: synthoidNode)
            }
        } else {
            // Empty space - build a rock
            buildRock(at: point)
        }
        return true
    }

    private func processLongPressFloor(node: SCNNode, point: GridPoint) -> Bool {
        guard grid.sentinelPosition != point,
            !grid.sentryPositions.contains(point),
            !grid.treePositions.contains(point),
            !grid.synthoidPositions.contains(point) else {
                return false
        }

        let viewingAngle = point.angle(to: grid.currentPosition)
        buildSynthoid(at: point, viewingAngle: viewingAngle)
        return true
    }

    private func processLongPressObject(node: SCNNode, point: GridPoint, interactiveNodeType: interactiveNodeType) -> Bool {
        if grid.sentinelPosition == point && interactiveNodeType == .sentinel {
            if let sentinelNode = node as? SentinelNode {
                absorb(sentinelNode: sentinelNode, point: point)
            }
        } else if grid.sentryPositions.contains(point) && interactiveNodeType == .sentry {
            if let sentryNode = node as? SentryNode {
                absorb(sentryNode: sentryNode, point: point)
            }
        } else if grid.treePositions.contains(point) && interactiveNodeType == .tree {
            if let treeNode = node as? TreeNode {
                absorb(treeNode: treeNode, point: point)
                return true
            }
        } else if grid.rockPositions.contains(point) && interactiveNodeType == .rock {
            if let rockNode = node as? RockNode {
                absorb(rockNode: rockNode, point: point)
                return true
            }
        } else if grid.synthoidPositions.contains(point) && interactiveNodeType == .synthoid {
            absorb(synthoidNode: node, point: point)
            return true
        }
        return false
    }

    private func move(to synthoidNode: SynthoidNode) {
        guard let floorNode = synthoidNode.floorNode,
            let point = playerNodeManipulator.point(for: floorNode)
            else {
                return
        }
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

    private func buildTree(at point: GridPoint, isPlayer: Bool = true) {
        guard hasEnergy(required: treeEnergyValue, isPlayer: isPlayer) else {
            return
        }

        grid.treePositions.insert(point)

        playerNodeManipulator.buildTree(at: point)
        opponentNodeManipulator.buildTree(at: point)

        adjustEnergy(delta: -treeEnergyValue, isPlayer: isPlayer)
    }

    private func buildRock(at point: GridPoint, isPlayer: Bool = true) {
        guard hasEnergy(required: treeEnergyValue, isPlayer: isPlayer) else {
            return
        }

        if (grid.treePositions.contains(point)) {
            adjustEnergy(delta: treeEnergyValue, isPlayer: isPlayer)
        }

        guard hasEnergy(required: rockEnergyValue, isPlayer: isPlayer) else {
            return
        }

        grid.rockPositions.insert(point)

        playerNodeManipulator.buildRock(at: point)
        opponentNodeManipulator.buildRock(at: point)

        adjustEnergy(delta: -rockEnergyValue, isPlayer: isPlayer)
    }

    private func buildSynthoid(at point: GridPoint, viewingAngle: Float) {
        guard hasEnergy(required: synthoidEnergyValue, isPlayer: true) else {
            return
        }

        grid.synthoidPositions.insert(point)

        playerNodeManipulator.buildSynthoid(at: point, viewingAngle: viewingAngle)
        opponentNodeManipulator.buildSynthoid(at: point, viewingAngle: viewingAngle)

        adjustEnergy(delta: -synthoidEnergyValue, isPlayer: true)
    }

    private func absorb(treeNode: TreeNode, point: GridPoint, isPlayer: Bool = true) {
        guard let index = grid.treePositions.index(of: point) else {
            return
        }

        playerNodeManipulator.absorbTree(at: point)
        opponentNodeManipulator.absorbTree(at: point)

        grid.treePositions.remove(at: index)

        adjustEnergy(delta: treeEnergyValue, isPlayer: isPlayer)
    }

    private func absorb(rockNode: RockNode, point: GridPoint, isPlayer: Bool = true) {
        guard let floorNode = rockNode.parent as? FloorNode else {
            return
        }

        // TODO: Tidy this up - can use topmost now?
        if grid.synthoidPositions.contains(point) {
            if let synthoidNode = floorNode.synthoidNode {
                absorb(synthoidNode: synthoidNode, point: point, isPlayer: isPlayer)
            }
        } else if grid.treePositions.contains(point) {
            if let treeNode = floorNode.treeNode {
                absorb(treeNode: treeNode, point: point, isPlayer: isPlayer)
            }
        }

        var absorbedRockNode: RockNode?
        repeat {
            absorbedRockNode = floorNode.removeLastRockNode()
            if absorbedRockNode != nil {
                adjustEnergy(delta: rockEnergyValue, isPlayer: isPlayer)
                if floorNode.rockNodes.count == 0 {
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

    private func absorb(synthoidNode: SCNNode, point: GridPoint, isPlayer: Bool = true) {
        guard let index = grid.synthoidPositions.index(of: point) else {
            return
        }

        playerNodeManipulator.absorbSynthoid(at: point)
        opponentNodeManipulator.absorbSynthoid(at: point)

        grid.synthoidPositions.remove(at: index)

        adjustEnergy(delta: synthoidEnergyValue, isPlayer: isPlayer)
    }

    private func absorb(sentryNode: SentryNode, point: GridPoint) {
        guard
            let delegate = delegate,
            let index = grid.sentryPositions.index(of: point),
            let floorNode = sentryNode.floorNode,
            let point = playerNodeManipulator.point(for: floorNode),
            let opponentFloorNode = opponentNodeManipulator.floorNode(for: point),
            let opponentSentryNode = opponentFloorNode.sentryNode
            else {
                return
        }

        playerNodeManipulator.absorbSentry(at: point)
        opponentNodeManipulator.absorbSentry(at: point)

        grid.sentryPositions.remove(at: index)

        adjustEnergy(delta: sentryEnergyValue, isPlayer: true)

        delegate.viewModel(self, didRemoveOpponent: opponentSentryNode.cameraNode)
    }

    private func absorb(sentinelNode: SentinelNode, point: GridPoint) {
        guard
            let delegate = delegate,
            let opponentSeninelNode = opponentNodeManipulator.terrainNode.sentinelNode
            else {
                return
        }

        playerNodeManipulator.absorbSentinel(at: point)
        opponentNodeManipulator.absorbSentinel(at: point)

        grid.sentinelPosition = undefinedPosition

        adjustEnergy(delta: sentinelEnergyValue, isPlayer: true)

        delegate.viewModel(self, didRemoveOpponent: opponentSeninelNode.cameraNode)
    }

    private func oppositionBuildRandomTree() {
        let gridIndex = GridIndex(grid: grid)
        let emptyPieces = gridIndex.allPieces()

        guard emptyPieces.count > 0 else {
            return
        }

        if let randomPiece = emptyPieces.randomElement() {
            buildTree(at: randomPiece.point, isPlayer: false)
        }
    }

    private func moveCamera(to nextSynthoidNode: SynthoidNode, animationDuration: CFTimeInterval) {
        guard let currentSynthoidNode = playerNodeManipulator.synthoidNode(at: grid.currentPosition) else {
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

    private func oppositionScan(in playerRenderer: SCNSceneRenderer) {
        guard let synthoidNode = playerNodeManipulator.synthoidNode(at: grid.currentPosition) else {
            return
        }

        for oppositionNode in playerNodeManipulator.terrainNode.oppositionNodes {
            if let visibleSynthoid = oppositionNode.visibleSynthoids(in: playerRenderer).randomElement() {
                if visibleSynthoid == synthoidNode {
                    print("SEEN")
                } else {
                    if let floorNode = visibleSynthoid.floorNode,
                        let point = playerNodeManipulator.point(for: floorNode) {
                        absorb(synthoidNode: visibleSynthoid, point: point, isPlayer: false)
                        buildRock(at: point, isPlayer: false)
                        oppositionBuildRandomTree()
                    }
                }
            } else if let visibleRock = oppositionNode.visibleRocks(in: playerRenderer).randomElement(),
                let floorNode = visibleRock.floorNode,
                let point = playerNodeManipulator.point(for: floorNode) {
                absorb(rockNode: visibleRock, point: point, isPlayer: false)
                buildTree(at: point, isPlayer: false)
                oppositionBuildRandomTree()
            } else if let visibleTree = oppositionNode.visibleTreesOnRocks(in: playerRenderer).randomElement(),
                let floorNode = visibleTree.floorNode,
                let point = playerNodeManipulator.point(for: floorNode) {
                absorb(treeNode: visibleTree, point: point, isPlayer: false)
                oppositionBuildRandomTree()
            }
        }
    }
}
