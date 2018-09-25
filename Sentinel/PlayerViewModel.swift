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

enum GameEndState {
    case victory, defeat
}

protocol PlayerViewModelDelegate: class {
    func playerViewModel(_: PlayerViewModel, didChange cameraNode: SCNNode)
    func playerViewModel(_: PlayerViewModel, levelDidEndWith state: GameEndState)
}

class PlayerViewModel: NSObject {
    private let levelConfiguration: LevelConfiguration
    private let terrainViewModel: TerrainViewModel
    private let initialCameraNode: SCNNode

    private let nodeManipulator: NodeManipulator
    private let grid: Grid

    let overlay = OverlayScene()

    weak var delegate: PlayerViewModelDelegate?

    var preAnimationBlock: (() -> Void)?
    var postAnimationBlock: (() -> Void)?

    init(levelConfiguration: LevelConfiguration, terrainViewModel: TerrainViewModel, initialCameraNode: SCNNode) {
        self.levelConfiguration = levelConfiguration
        self.terrainViewModel = terrainViewModel
        self.initialCameraNode = initialCameraNode

        self.nodeManipulator = terrainViewModel.nodeManipulator
        self.grid = terrainViewModel.grid
        overlay.energy = 10

        super.init()
    }

    func cameraNode(for viewer: Viewer) -> SCNNode? {
        if let viewingNode = nodeManipulator.viewingNode(for: viewer) {
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
        nodeManipulator.rotateCurrentSynthoid(by: angleDeltaRadians)

        if finished {
            nodeManipulator.rotateCurrentSynthoid(by: angleDeltaRadians, persist: true)
        }
    }

    func adjustEnergy(delta: Int) {
        guard
            let delegate = delegate
            else {
                return
        }

        overlay.energy += delta

        if overlay.energy <= 0 {
            delegate.playerViewModel(self, levelDidEndWith: .defeat)
        }
    }

    private func hasEnergy(required: Int) -> Bool {
        return overlay.energy > required
    }

    private func hasEnteredScene() -> Bool {
        return grid.currentPosition != undefinedPosition
    }

    private func enterScene() -> Bool {
        guard let synthoidNode = nodeManipulator.synthoidNode(at: grid.startPosition) else {
            return false
        }

        moveCamera(from: initialCameraNode,
                   to: synthoidNode.cameraNode,
                   animationDuration: 3.0)
        grid.currentPosition = grid.startPosition

        nodeManipulator.makeSynthoidCurrent(at: grid.currentPosition)

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
            point = nodeManipulator.point(for: floorNode)
        } else if let floorNode = node.parent as? FloorNode,
            let floorName = floorNode.name,
            floorName == floorNodeName {
            point = nodeManipulator.point(for: floorNode)
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
            let point = nodeManipulator.point(for: floorNode)
            else {
                return
        }

        moveCamera(to: synthoidNode, animationDuration: 1.0)
        grid.currentPosition = point
        nodeManipulator.makeSynthoidCurrent(at: grid.currentPosition)
    }

    private func buildTree(at point: GridPoint) {
        guard hasEnergy(required: treeEnergyValue) else {
            return
        }

        adjustEnergy(delta: -treeEnergyValue)
        terrainViewModel.buildTree(at: point)
    }

    private func buildRock(at point: GridPoint, isPlayer: Bool = true) {
        guard hasEnergy(required: treeEnergyValue) else {
            return
        }

        if (grid.treePositions.contains(point)) {
            adjustEnergy(delta: treeEnergyValue)
        }

        guard hasEnergy(required: rockEnergyValue) else {
            return
        }

        adjustEnergy(delta: -rockEnergyValue)
        terrainViewModel.buildRock(at: point)
    }

    private func buildSynthoid(at point: GridPoint, viewingAngle: Float) {
        guard hasEnergy(required: synthoidEnergyValue) else {
            return
        }

        adjustEnergy(delta: -synthoidEnergyValue)
        terrainViewModel.buildSynthoid(at: point, viewingAngle: viewingAngle)
    }

    private func absorbTreeNode(at point: GridPoint) {
        if terrainViewModel.absorbTreeNode(at: point) {
            adjustEnergy(delta: treeEnergyValue)
        }
    }

    private func absorbRockNode(at point: GridPoint, height: Int) {
        if terrainViewModel.absorbRockNode(at: point, height: height) {
            adjustEnergy(delta: rockEnergyValue)
        }
    }

    private func absorbSynthoidNode(at point: GridPoint) {
        if terrainViewModel.absorbSynthoidNode(at: point) {
            adjustEnergy(delta: synthoidEnergyValue)
        }
    }

    private func absorbSentryNode(at point: GridPoint) {
        if nodeManipulator.absorbSentry(at: point) {
            adjustEnergy(delta: sentryEnergyValue)
        }
    }

    private func absorbSentinelNode(at point: GridPoint) {
        guard let delegate = delegate else {
            return
        }

        if nodeManipulator.absorbSentinel(at: point) {
            adjustEnergy(delta: sentinelEnergyValue)
            delegate.playerViewModel(self, levelDidEndWith: .victory)
        }
    }

    private func moveCamera(to nextSynthoidNode: SynthoidNode, animationDuration: CFTimeInterval) {
        guard let currentSynthoidNode = nodeManipulator.currentSynthoidNode else {
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
        delegate.playerViewModel(self, didChange: transitionCameraNode)

        SCNTransaction.begin()
        SCNTransaction.animationDuration = animationDuration
        SCNTransaction.completionBlock = {
            delegate.playerViewModel(self, didChange: to)
            transitionCameraNode.removeFromParentNode()
            if let postAnimationBlock = self.postAnimationBlock {
                postAnimationBlock()
            }
        }

        transitionCameraNode.setWorldTransform(to.worldTransform)

        SCNTransaction.commit()
    }
}
