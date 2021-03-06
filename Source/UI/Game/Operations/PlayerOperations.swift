import SceneKit
import SpriteKit

let treeEnergyValue = 1
let rockEnergyValue = 2
let synthoidEnergyValue = 3
let sentryEnergyValue = 3
let sentinelEnergyValue = 4

enum GameEndState {
    case victory, defeat
}

protocol PlayerOperationsDelegate: AnyObject {
    func playerOperations(_: PlayerOperations, didChange cameraNode: SCNNode)
    func playerOperations(_: PlayerOperations, levelDidEndWith state: GameEndState)
}

class PlayerOperations {
    private let levelConfiguration: LevelConfiguration
    private let terrainOperations: TerrainOperations
    private let initialCameraNode: SCNNode

    private let nodeManipulator: NodeManipulator
    private let grid: Grid

    let overlay = OverlayScene()

    weak var delegate: PlayerOperationsDelegate?

    var preAnimationBlock: (() -> Void)?
    var postAnimationBlock: (() -> Void)?

    init(levelConfiguration: LevelConfiguration, terrainOperations: TerrainOperations, initialCameraNode: SCNNode) {
        self.levelConfiguration = levelConfiguration
        self.terrainOperations = terrainOperations
        self.initialCameraNode = initialCameraNode

        nodeManipulator = terrainOperations.nodeManipulator
        grid = terrainOperations.grid
        overlay.energy = 10
    }

    func adjustEnergy(delta: Int) {
        guard
            let delegate = delegate
        else {
            return
        }

        overlay.energy += delta

        if overlay.energy <= 0 {
            delegate.playerOperations(self, levelDidEndWith: .defeat)
        }
    }

    private func hasEnergy(required: Int) -> Bool {
        return overlay.energy > required
    }

    func hasEnteredScene() -> Bool {
        return grid.currentPosition != undefinedPosition
    }

    func enterScene() -> Bool {
        guard let synthoidNode = nodeManipulator.synthoidNode(at: grid.startPosition) else {
            return false
        }

        moveCamera(from: initialCameraNode,
                   to: synthoidNode.cameraNode,
                   animationDuration: 3.0)
        grid.currentPosition = grid.startPosition

        nodeManipulator.makeSynthoidCurrent(at: grid.currentPosition)

        return false
    }

    func move(to synthoidNode: SynthoidNode) {
        guard let floorNode = synthoidNode.floorNode,
            let point = nodeManipulator.point(for: floorNode)
        else {
            return
        }

        moveCamera(to: synthoidNode, animationDuration: 1.0)
        grid.currentPosition = point
        nodeManipulator.makeSynthoidCurrent(at: grid.currentPosition)
    }

    func buildTree(at point: GridPoint) {
        guard hasEnergy(required: treeEnergyValue) else {
            return
        }

        adjustEnergy(delta: -treeEnergyValue)
        terrainOperations.buildTree(at: point)
    }

    func buildRock(at point: GridPoint, rotation: Float? = nil) {
        guard hasEnergy(required: treeEnergyValue) else {
            return
        }

        if grid.treePositions.contains(point) {
            adjustEnergy(delta: treeEnergyValue)
        }

        guard hasEnergy(required: rockEnergyValue) else {
            return
        }

        adjustEnergy(delta: -rockEnergyValue)
        terrainOperations.buildRock(at: point, rotation: rotation)
    }

    func buildSynthoid(at point: GridPoint) {
        guard hasEnergy(required: synthoidEnergyValue) else {
            return
        }

        let viewingAngle = point.angle(to: grid.currentPosition)
        adjustEnergy(delta: -synthoidEnergyValue)
        terrainOperations.buildSynthoid(at: point, viewingAngle: viewingAngle)
    }

    func absorbTopmostNode(at point: GridPoint) -> Bool {
        if let floorNode = nodeManipulator.floorNode(for: point),
            let topmostNode = floorNode.topmostNode {
            if topmostNode is TreeNode {
                return absorbTreeNode(at: point)
            }
            if topmostNode is RockNode {
                return absorbRockNode(at: point, isFinalRockNode: floorNode.rockNodes.count == 1)
            }
            if topmostNode is SynthoidNode {
                return absorbSynthoidNode(at: point)
            }
            if topmostNode is SentryNode {
                return absorbSentryNode(at: point)
            }
            if topmostNode is SentinelNode {
                return absorbSentinelNode(at: point)
            }
        }
        return false
    }

    func absorbTreeNode(at point: GridPoint) -> Bool {
        if terrainOperations.absorbTreeNode(at: point) {
            adjustEnergy(delta: treeEnergyValue)
            return true
        }
        return false
    }

    func absorbRockNode(at point: GridPoint, isFinalRockNode: Bool) -> Bool {
        if terrainOperations.absorbRockNode(at: point, isFinalRockNode: isFinalRockNode) {
            adjustEnergy(delta: rockEnergyValue)
            return true
        }
        return false
    }

    func absorbSynthoidNode(at point: GridPoint) -> Bool {
        if terrainOperations.absorbSynthoidNode(at: point) {
            adjustEnergy(delta: synthoidEnergyValue)
            return true
        }
        return false
    }

    func absorbSentryNode(at point: GridPoint) -> Bool {
        if nodeManipulator.absorbSentry(at: point) {
            adjustEnergy(delta: sentryEnergyValue)
            return true
        }
        return false
    }

    func absorbSentinelNode(at point: GridPoint) -> Bool {
        guard let delegate = delegate else {
            return false
        }

        if nodeManipulator.absorbSentinel(at: point) {
            adjustEnergy(delta: sentinelEnergyValue)
            delegate.playerOperations(self, levelDidEndWith: .victory)
            return true
        }

        return false
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
        delegate.playerOperations(self, didChange: transitionCameraNode)

        SCNTransaction.begin()
        SCNTransaction.animationDuration = animationDuration
        SCNTransaction.completionBlock = {
            delegate.playerOperations(self, didChange: to)
            transitionCameraNode.removeFromParentNode()
            if let postAnimationBlock = self.postAnimationBlock {
                postAnimationBlock()
            }
        }

        transitionCameraNode.setWorldTransform(to.worldTransform)

        SCNTransaction.commit()
    }
}
