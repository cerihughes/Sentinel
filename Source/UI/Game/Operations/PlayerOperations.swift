import SceneKit
import SpriteKit

let treeEnergyValue = 1
let rockEnergyValue = 2
let synthoidEnergyValue = 3
let sentryEnergyValue = 3
let sentinelEnergyValue = 4

enum PlayerOperation {
    case build(BuildableItem)
    case absorb(AbsorbableItem)
    case teleport(GridPoint)
}

protocol PlayerOperationsDelegate: AnyObject {
    func playerOperations(_ playerOperations: PlayerOperations, didChange cameraNode: SCNNode)
    func playerOperations(_ playerOperations: PlayerOperations, didPerform operation: PlayerOperation)
}

class PlayerOperations {
    enum Item {
        case tree, rock, synthoid, sentry, sentinel
    }
    private let levelConfiguration: LevelConfiguration
    private let terrainOperations: TerrainOperations
    private let initialCameraNode: SCNNode

    private let nodeManipulator: NodeManipulator
    private let grid: Grid
    private let synthoidEnergy: SynthoidEnergy

    weak var delegate: PlayerOperationsDelegate?

    var preAnimationBlock: (() -> Void)?
    var postAnimationBlock: (() -> Void)?

    init(
        levelConfiguration: LevelConfiguration,
        terrainOperations: TerrainOperations,
        synthoidEnergy: SynthoidEnergy,
        initialCameraNode: SCNNode
    ) {
        self.levelConfiguration = levelConfiguration
        self.terrainOperations = terrainOperations
        self.synthoidEnergy = synthoidEnergy
        self.initialCameraNode = initialCameraNode

        nodeManipulator = terrainOperations.nodeManipulator
        grid = terrainOperations.grid
    }

    func hasEnteredScene() -> Bool {
        return grid.currentPosition != .undefined
    }

    func enterScene() -> Bool {
        guard let synthoidNode = nodeManipulator.synthoidNode(at: grid.startPosition) else {
            return false
        }

        moveCamera(from: initialCameraNode,
                   to: synthoidNode.cameraNode,
                   animationDuration: 3.0)
        grid.currentPosition = grid.startPosition
        delegate?.playerOperations(self, didPerform: .teleport(grid.currentPosition))

        nodeManipulator.makeSynthoidCurrent(at: grid.currentPosition)

        return false
    }

    func move(to synthoidNode: SynthoidNode) {
        guard let floorNode = synthoidNode.floorNode, let point = nodeManipulator.point(for: floorNode) else {
            return
        }

        moveCamera(to: synthoidNode, gridPoint: point, animationDuration: 1.0)
        grid.currentPosition = point
        nodeManipulator.makeSynthoidCurrent(at: grid.currentPosition)
    }

    func buildTree(at point: GridPoint) {
        guard synthoidEnergy.has(energy: treeEnergyValue) else {
            return
        }

        synthoidEnergy.adjust(delta: -treeEnergyValue)
        terrainOperations.buildTree(at: point)
        delegate?.playerOperations(self, didPerform: .build(.tree))
    }

    func buildRock(at point: GridPoint, rotation: Float? = nil) {
        guard synthoidEnergy.has(energy: rockEnergyValue) else {
            return
        }

        synthoidEnergy.adjust(delta: -rockEnergyValue)
        terrainOperations.buildRock(at: point, rotation: rotation)
        delegate?.playerOperations(self, didPerform: .build(.rock))
    }

    func buildSynthoid(at point: GridPoint) {
        guard synthoidEnergy.has(energy: synthoidEnergyValue) else {
            return
        }

        let viewingAngle = point.angle(to: grid.currentPosition)
        synthoidEnergy.adjust(delta: -synthoidEnergyValue)
        terrainOperations.buildSynthoid(at: point, viewingAngle: viewingAngle)
        delegate?.playerOperations(self, didPerform: .build(.synthoid))
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

    private func absorbTreeNode(at point: GridPoint) -> Bool {
        if terrainOperations.absorbTreeNode(at: point) {
            synthoidEnergy.adjust(delta: treeEnergyValue)
            delegate?.playerOperations(self, didPerform: .absorb(.tree))
            return true
        }
        return false
    }

    private func absorbRockNode(at point: GridPoint, isFinalRockNode: Bool) -> Bool {
        if terrainOperations.absorbRockNode(at: point, isFinalRockNode: isFinalRockNode) {
            synthoidEnergy.adjust(delta: rockEnergyValue)
            delegate?.playerOperations(self, didPerform: .absorb(.rock))
            return true
        }
        return false
    }

    private func absorbSynthoidNode(at point: GridPoint) -> Bool {
        if terrainOperations.absorbSynthoidNode(at: point) {
            synthoidEnergy.adjust(delta: synthoidEnergyValue)
            delegate?.playerOperations(self, didPerform: .absorb(.synthoid))
            return true
        }
        return false
    }

    private func absorbSentryNode(at point: GridPoint) -> Bool {
        if nodeManipulator.absorbSentry(at: point) {
            synthoidEnergy.adjust(delta: sentryEnergyValue)
            delegate?.playerOperations(self, didPerform: .absorb(.sentry))
            return true
        }
        return false
    }

    private func absorbSentinelNode(at point: GridPoint) -> Bool {
        if nodeManipulator.absorbSentinel(at: point) {
            synthoidEnergy.adjust(delta: sentinelEnergyValue)
            delegate?.playerOperations(self, didPerform: .absorb(.sentinel))
            return true
        }

        return false
    }

    private func moveCamera(
        to nextSynthoidNode: SynthoidNode,
        gridPoint: GridPoint,
        animationDuration: CFTimeInterval
    ) {
        guard let currentSynthoidNode = nodeManipulator.currentSynthoidNode else { return }
        moveCamera(
            from: currentSynthoidNode.cameraNode,
            to: nextSynthoidNode.cameraNode,
            animationDuration: animationDuration
        )
        self.delegate?.playerOperations(self, didPerform: .teleport(gridPoint))
    }

    private func moveCamera(from: SCNNode, to: SCNNode, animationDuration: CFTimeInterval) {
        guard let parent = from.parent else { return }

        preAnimationBlock?()

        let transitionCameraNode = from.clone()
        parent.addChildNode(transitionCameraNode)
        delegate?.playerOperations(self, didChange: transitionCameraNode)

        SCNTransaction.begin()
        SCNTransaction.animationDuration = animationDuration
        SCNTransaction.completionBlock = {
            self.delegate?.playerOperations(self, didChange: to)
            transitionCameraNode.removeFromParentNode()
            self.postAnimationBlock?()
        }

        transitionCameraNode.setWorldTransform(to.worldTransform)

        SCNTransaction.commit()
    }
}
