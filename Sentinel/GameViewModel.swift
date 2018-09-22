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

protocol GameViewModelDelegate: class {
    func gameViewModel(_: GameViewModel, didChange cameraNode: SCNNode)
    func gameViewModel(_: GameViewModel, didDetectOpponent cameraNode: SCNNode)
    func gameViewModel(_: GameViewModel, didEndDetectOpponent cameraNode: SCNNode)
}

class GameViewModel: NSObject, SCNSceneRendererDelegate {
    let levelConfiguration: LevelConfiguration
    let overlay = SKScene()
    let world: World
    weak var delegate: GameViewModelDelegate?
    var preAnimationBlock: (() -> Void)?
    var postAnimationBlock: (() -> Void)?

    private let grid: Grid
    private let timeMachine = TimeMachine()
    private var energy: Int = 10
    private let worldManipulator: WorldManipulator

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

        let playerNodeManipulator = NodeManipulator(terrainNode: playerTerrainNode, nodeMap: playerNodeMap, nodeFactory: nodeFactory)
        let opponentNodeManipulator = NodeManipulator(terrainNode: opponentTerrainNode, nodeMap: opponentNodeMap, nodeFactory: nodeFactory)

        worldManipulator = WorldManipulator(playerNodeManipulator: playerNodeManipulator,
                                            opponentNodeManipulator: opponentNodeManipulator)

        super.init()

        setupTimingFunctions()
    }

    func cameraNode(for viewer: Viewer) -> SCNNode? {
        if let viewingNode = worldManipulator.viewingNode(for: viewer) {
            return viewingNode.cameraNode
        }
        return nil
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
        let angleDeltaDegrees = x / 10.0
        let angleDeltaRadians = angleDeltaDegrees * Float.pi / 180.0
        worldManipulator.rotateCurrentSynthoid(by: angleDeltaRadians)

        if finished {
            worldManipulator.rotateCurrentSynthoid(by: angleDeltaRadians, persist: true)
        }
    }

    private func hasEnteredScene() -> Bool {
        return grid.currentPosition != undefinedPosition
    }

    private func enterScene() -> Bool {
        guard let synthoidNode = worldManipulator.playerNodeManipulator.synthoidNode(at: grid.startPosition) else {
            return false
        }

        moveCamera(from: world.initialCameraNode,
                   to: synthoidNode.cameraNode,
                   animationDuration: 3.0)
        grid.currentPosition = grid.startPosition

        worldManipulator.makeSynthoidCurrent(at: grid.currentPosition)

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
            point = worldManipulator.playerNodeManipulator.point(for: floorNode)
        } else if let floorNode = node.parent as? FloorNode,
            let floorName = floorNode.name,
            floorName == floorNodeName {
            point = worldManipulator.playerNodeManipulator.point(for: floorNode)
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
            absorbSentinelNode(at: point)
        } else if grid.sentryPositions.contains(point) && interactiveNodeType == .sentry {
            absorbSentryNode(at: point)
        } else if grid.treePositions.contains(point) && interactiveNodeType == .tree {
            absorbTreeNode(at: point)
        } else if grid.rockPositions.contains(point) && interactiveNodeType == .rock {
            if let rockNode = node as? RockNode,
                let floorNode = rockNode.floorNode,
                let height = floorNode.rockNodes.firstIndex(of: rockNode) {
                absorbRockNode(at: point, height: height)
            }
        } else if grid.synthoidPositions.contains(point) && interactiveNodeType == .synthoid {
            absorbSynthoidNode(at: point)

        }
        return true
    }

    private func move(to synthoidNode: SynthoidNode) {
        guard let floorNode = synthoidNode.floorNode,
            let point = worldManipulator.playerNodeManipulator.point(for: floorNode)
            else {
                return
        }

        moveCamera(to: synthoidNode, animationDuration: 1.0)

        grid.currentPosition = point
        
        worldManipulator.makeSynthoidCurrent(at: grid.currentPosition)
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
        worldManipulator.buildTree(at: point)
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
        worldManipulator.buildRock(at: point)
        adjustEnergy(delta: -rockEnergyValue, isPlayer: isPlayer)
    }

    private func buildSynthoid(at point: GridPoint, viewingAngle: Float) {
        guard hasEnergy(required: synthoidEnergyValue, isPlayer: true) else {
            return
        }

        grid.synthoidPositions.insert(point)
        worldManipulator.buildSynthoid(at: point, viewingAngle: viewingAngle)
        adjustEnergy(delta: -synthoidEnergyValue, isPlayer: true)
    }

    private func absorbTreeNode(at point: GridPoint, isPlayer: Bool = true) {
        guard let index = grid.treePositions.index(of: point) else {
            return
        }

        if worldManipulator.absorbTree(at: point) {
            grid.treePositions.remove(at: index)
            adjustEnergy(delta: treeEnergyValue, isPlayer: isPlayer)
        }
    }

    private func absorbRockNode(at point: GridPoint, height: Int, isPlayer: Bool = true) {
        guard let index = grid.rockPositions.index(of: point) else {
            return
        }

        if grid.synthoidPositions.contains(point) {
            absorbSynthoidNode(at: point, isPlayer: isPlayer)
        } else if grid.treePositions.contains(point) {
            absorbTreeNode(at: point, isPlayer: isPlayer)
        }

        var absorbed = true
        repeat {
            absorbed = worldManipulator.absorbRock(at: point, height: height)
            if absorbed {
                adjustEnergy(delta: rockEnergyValue, isPlayer: isPlayer)
            }
        } while absorbed

        if height == 0 {
            grid.rockPositions.remove(at: index)
        }
    }

    private func absorbSynthoidNode(at point: GridPoint, isPlayer: Bool = true) {
        guard let index = grid.synthoidPositions.index(of: point) else {
            return
        }

        if worldManipulator.absorbSynthoid(at: point) {
            grid.synthoidPositions.remove(at: index)
            adjustEnergy(delta: synthoidEnergyValue, isPlayer: isPlayer)
        }
    }

    private func absorbSentryNode(at point: GridPoint) {
        guard
            let delegate = delegate,
            let index = grid.sentryPositions.index(of: point),
            let opponentSentryNode = worldManipulator.opponentOppositionNode(at: point)
            else {
                return
        }

        if worldManipulator.absorbSentry(at: point) {
            delegate.gameViewModel(self, didEndDetectOpponent: opponentSentryNode.cameraNode)
            grid.sentryPositions.remove(at: index)
            adjustEnergy(delta: sentryEnergyValue, isPlayer: true)
        }
    }

    private func absorbSentinelNode(at point: GridPoint) {
        guard
            let delegate = delegate,
            let opponentSentinelNode = worldManipulator.opponentOppositionNode(at: point)
            else {
                return
        }

        if worldManipulator.absorbSentinel(at: point) {
            delegate.gameViewModel(self, didEndDetectOpponent: opponentSentinelNode.cameraNode)
            grid.sentinelPosition = undefinedPosition
            adjustEnergy(delta: sentinelEnergyValue, isPlayer: true)
        }
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
        guard let currentSynthoidNode = worldManipulator.currentSynthoidNode else {
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
        delegate.gameViewModel(self, didChange: transitionCameraNode)

        SCNTransaction.begin()
        SCNTransaction.animationDuration = animationDuration
        SCNTransaction.completionBlock = {
            delegate.gameViewModel(self, didChange: to)
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
        timeMachine.handle(currentTimeInterval: time, renderer: renderer)
    }
}

extension GameViewModel {
    fileprivate func setupTimingFunctions() {
        _ = timeMachine.add(timeInterval: 2.0, function: oppositionAbsorbObjects(timeInterval:playerRenderer:lastResult:))
        _ = timeMachine.add(timeInterval: levelConfiguration.opponentRotationPause, function: oppositionRotation(timeInterval:playerRenderer:lastResult:))
        _ = timeMachine.add(timeInterval: 2.0, function: oppositionDetection(timeInterval:playerRenderer:lastResult:))
    }

    private func oppositionAbsorbObjects(timeInterval: TimeInterval, playerRenderer: SCNSceneRenderer, lastResult: Any?) -> Any? {
        guard let synthoidNode = worldManipulator.currentSynthoidNode else {
            return nil
        }

        let playerNodeManipulator = worldManipulator.playerNodeManipulator
        for oppositionNode in playerNodeManipulator.terrainNode.oppositionNodes {
            let visibleSynthoids = oppositionNode.visibleSynthoids(in: playerRenderer)
            if visibleSynthoids.contains(synthoidNode) {
                return nil // Don't absorb the player - this is handled by a separate timing function
            }

            if let visibleSynthoid = visibleSynthoids.randomElement(),
                let floorNode = visibleSynthoid.floorNode,
                let point = playerNodeManipulator.point(for: floorNode) {
                absorbSynthoidNode(at: point, isPlayer: false)
                buildRock(at: point, isPlayer: false)
                oppositionBuildRandomTree()
                return nil
            }

            if let visibleRock = oppositionNode.visibleRocks(in: playerRenderer).randomElement(),
                let floorNode = visibleRock.floorNode,
                let point = playerNodeManipulator.point(for: floorNode) {
                absorbRockNode(at: point, height: floorNode.rockNodes.count - 1, isPlayer: false)
                buildTree(at: point, isPlayer: false)
                oppositionBuildRandomTree()
                return nil
            }

            if let visibleTree = oppositionNode.visibleTreesOnRocks(in: playerRenderer).randomElement(),
                let floorNode = visibleTree.floorNode,
                let point = playerNodeManipulator.point(for: floorNode) {
                absorbTreeNode(at: point, isPlayer: false)
                oppositionBuildRandomTree()
                return nil
            }
        }
        return nil
    }

    private func oppositionRotation(timeInterval: TimeInterval, playerRenderer: SCNSceneRenderer, lastResult: Any?) -> Any? {
        let radians = 2.0 * Float.pi / Float(levelConfiguration.opponentRotationSteps)
        let duration = levelConfiguration.opponentRotationTime
        worldManipulator.rotateAllOpposition(by: radians, duration: duration)
        return nil
    }

    private func oppositionDetection(timeInterval: TimeInterval, playerRenderer: SCNSceneRenderer, lastResult: Any?) -> Any? {
        guard
            let delegate = delegate,
            let synthoidNode = worldManipulator.currentSynthoidNode
            else {
                return lastResult
        }

        let playerOppositionNodes = self.worldManipulator.playerNodeManipulator.terrainNode.oppositionNodes
        let detectingPlayerOppositionNodes = nodes(playerOppositionNodes, thatSee: synthoidNode, in: playerRenderer)
        let detecingOpponentOppositionNodes = worldManipulator.opponentOppositionNodes(for: detectingPlayerOppositionNodes)
        let detectingCameraNodes = Set(detecingOpponentOppositionNodes.map { $0.cameraNode })
        let lastCameraNodes = lastResult as? Set<SCNNode> ?? []

        for detectingCameraNode in detectingCameraNodes {
            if !lastCameraNodes.contains(detectingCameraNode) {
                delegate.gameViewModel(self, didDetectOpponent: detectingCameraNode)
            }
        }

        for lastCameraNode in lastCameraNodes {
            if !detectingCameraNodes.contains(lastCameraNode) {
                delegate.gameViewModel(self, didEndDetectOpponent: lastCameraNode)
            }
        }

        return detectingCameraNodes
    }

    private func nodes(_ oppositionNodes: [OppositionNode],
                       thatSee synthoidNode: SynthoidNode,
                       in playerRenderer: SCNSceneRenderer) -> [OppositionNode] {
        var detectingOppositionNodes: [OppositionNode] = []
        for oppositionNode in oppositionNodes {
            let detectableSynthoids = oppositionNode.visibleSynthoids(in: playerRenderer)
            if detectableSynthoids.contains(synthoidNode) {
                detectingOppositionNodes.append(oppositionNode)
            }
        }
        return detectingOppositionNodes
    }
}