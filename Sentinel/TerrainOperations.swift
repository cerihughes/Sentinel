import SceneKit
import SpriteKit

class TerrainOperations {
    let grid: Grid
    let nodeManipulator: NodeManipulator

    init(grid: Grid, nodeManipulator: NodeManipulator) {
        self.grid = grid
        self.nodeManipulator = nodeManipulator
    }

    func buildTree(at point: GridPoint) {
        grid.treePositions.insert(point)
        nodeManipulator.buildTree(at: point)
    }

    func buildRock(at point: GridPoint, rotation: Float? = nil) {
        grid.rockPositions.insert(point)
        nodeManipulator.buildRock(at: point, rotation: rotation)
    }

    func buildSynthoid(at point: GridPoint, viewingAngle: Float) {
        grid.synthoidPositions.insert(point)
        nodeManipulator.buildSynthoid(at: point, viewingAngle: viewingAngle)
    }

    func absorbTopmostNode(at point: GridPoint) -> Bool {
        if let floorNode = nodeManipulator.floorNode(for: point),
            let topmostNode = floorNode.topmostNode {
            if topmostNode is TreeNode {
                return absorbTreeNode(at: point)
            }
            if topmostNode is RockNode {
                return absorbRockNode(at: point, isFinalRockNode: topmostNode == floorNode.rockNodes.last)
            }
            if topmostNode is SynthoidNode {
                return  absorbSynthoidNode(at: point)
            }
        }
        return false
    }

    func absorbTreeNode(at point: GridPoint) -> Bool {
        guard
            nodeManipulator.absorbTree(at: point),
            let index = grid.treePositions.index(of: point)
            else {
                return false
        }

        grid.treePositions.remove(at: index)
        return true
    }

    func absorbRockNode(at point: GridPoint, isFinalRockNode: Bool) -> Bool {
        guard let index = grid.rockPositions.index(of: point) else {
            return false
        }

        if grid.synthoidPositions.contains(point) {
            return absorbSynthoidNode(at: point)
        } else if grid.treePositions.contains(point) {
            return absorbTreeNode(at: point)
        }

        if nodeManipulator.absorbRock(at: point) {
            if isFinalRockNode {
                grid.rockPositions.remove(at: index)
            }
        }

        return true
    }

    func absorbSynthoidNode(at point: GridPoint) -> Bool {
        guard
            nodeManipulator.absorbSynthoid(at: point),
            let index = grid.synthoidPositions.index(of: point)
            else {
                return false
        }

        grid.synthoidPositions.remove(at: index)
        return true
    }

    func absorbSentryNode(at point: GridPoint) -> Bool {
        guard
            nodeManipulator.absorbSentry(at: point),
            let index = grid.sentryPositions.index(of: point)
            else {
                return false
        }

        grid.sentryPositions.remove(at: index)
        return true
    }

    func absorbSentinelNode(at point: GridPoint) -> Bool {
        guard nodeManipulator.absorbSentinel(at: point) else {
            return false
        }

        grid.sentinelPosition = undefinedPosition
        return true
    }
}
