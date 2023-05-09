import SceneKit
import SpriteKit

extension Int {
    static let treeEnergyValue = 1
    static let rockEnergyValue = 2
    static let synthoidEnergyValue = 3
    static let sentryEnergyValue = 3
    static let sentinelEnergyValue = 4
}

enum PlayerOperation {
    case enterScene(GridPoint)
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
    private let terrainOperations: TerrainOperations
    private let initialCameraNode: SCNNode

    private let nodeManipulator: NodeManipulator
    private var grid: Grid
    private let synthoidEnergy: SynthoidEnergy

    weak var delegate: PlayerOperationsDelegate?

    var preAnimationBlock: (() -> Void)?
    var postAnimationBlock: (() -> Void)?

    init(
        terrainOperations: TerrainOperations,
        synthoidEnergy: SynthoidEnergy,
        initialCameraNode: SCNNode
    ) {
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
        guard let synthoidNode = nodeManipulator.synthoidNode(at: grid.startPosition) else { return false }

        moveCamera(from: initialCameraNode,
                   to: synthoidNode.cameraNode,
                   animationDuration: 3.0)
        grid.currentPosition = grid.startPosition
        delegate?.playerOperations(self, didPerform: .enterScene(grid.currentPosition))

        nodeManipulator.makeSynthoidCurrent(at: grid.currentPosition)

        return true
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
        guard synthoidEnergy.has(energy: .treeEnergyValue) else {
            return
        }

        synthoidEnergy.adjust(delta: -.treeEnergyValue)
        terrainOperations.buildTree(at: point)
        delegate?.playerOperations(self, didPerform: .build(.tree))
    }

    func buildRock(at point: GridPoint, rotation: Float? = nil) {
        guard synthoidEnergy.has(energy: .rockEnergyValue) else {
            return
        }

        synthoidEnergy.adjust(delta: -.rockEnergyValue)
        terrainOperations.buildRock(at: point, rotation: rotation)
        delegate?.playerOperations(self, didPerform: .build(.rock))
    }

    func buildSynthoid(at point: GridPoint) {
        guard synthoidEnergy.has(energy: .synthoidEnergyValue) else { return }

        let viewingAngle = point.angle(to: grid.currentPosition)
        synthoidEnergy.adjust(delta: -.synthoidEnergyValue)
        terrainOperations.buildSynthoid(at: point, viewingAngle: viewingAngle)
        delegate?.playerOperations(self, didPerform: .build(.synthoid))
    }

    func absorbTopmostNode(at point: GridPoint) {
        if let floorNode = nodeManipulator.floorNode(for: point),
            let topmostNode = floorNode.topmostNode {
            if topmostNode is TreeNode {
                absorbTreeNode(at: point)
            } else if topmostNode is RockNode {
                absorbRockNode(at: point)
            } else if topmostNode is SynthoidNode {
                absorbSynthoidNode(at: point)
            } else if topmostNode is SentryNode {
                absorbSentryNode(at: point)
            } else if topmostNode is SentinelNode {
                absorbSentinelNode(at: point)
            }
        }
    }

    private func absorbTreeNode(at point: GridPoint) {
        terrainOperations.absorbTreeNode(at: point)
        synthoidEnergy.adjust(delta: .treeEnergyValue)
        delegate?.playerOperations(self, didPerform: .absorb(.tree))
    }

    private func absorbRockNode(at point: GridPoint) {
        terrainOperations.absorbRockNode(at: point)
        synthoidEnergy.adjust(delta: .rockEnergyValue)
        delegate?.playerOperations(self, didPerform: .absorb(.rock))
    }

    private func absorbSynthoidNode(at point: GridPoint) {
        terrainOperations.absorbSynthoidNode(at: point)
        synthoidEnergy.adjust(delta: .synthoidEnergyValue)
        delegate?.playerOperations(self, didPerform: .absorb(.synthoid))
    }

    private func absorbSentryNode(at point: GridPoint) {
        nodeManipulator.absorbSentry(at: point, animated: false)
        synthoidEnergy.adjust(delta: .sentryEnergyValue)
        delegate?.playerOperations(self, didPerform: .absorb(.sentry))
    }

    private func absorbSentinelNode(at point: GridPoint) {
        nodeManipulator.absorbSentinel(at: point, animated: false)
        synthoidEnergy.adjust(delta: .sentinelEnergyValue)
        delegate?.playerOperations(self, didPerform: .absorb(.sentinel))
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
