import SceneKit
import SpriteKit

class TerrainOperations {
    var grid: Grid
    let nodeManipulator: NodeManipulator

    init(grid: Grid, nodeManipulator: NodeManipulator) {
        self.grid = grid
        self.nodeManipulator = nodeManipulator
    }

    func buildTree(at point: GridPoint) {
        grid.treePositions.append(point)
        nodeManipulator.buildTree(at: point)
    }

    func buildRock(at point: GridPoint, rotation: Float? = nil) {
        grid.addRock(at: point)
        nodeManipulator.buildRock(at: point, rotation: rotation)
    }

    func buildSynthoid(at point: GridPoint, viewingAngle: Float) {
        grid.synthoidPositions.append(point)
        nodeManipulator.buildSynthoid(at: point, viewingAngle: viewingAngle)
    }

    func absorbTreeNode(at point: GridPoint, animated: Bool = false, completion: (() -> Void)? = nil) {
        guard let index = grid.treePositions.firstIndex(of: point) else { return }

        nodeManipulator.absorbTree(at: point, animated: animated, completion: completion)
        grid.treePositions.remove(at: index)
    }

    func absorbRockNode(at point: GridPoint, animated: Bool = false, completion: (() -> Void)? = nil) {
        if grid.synthoidPositions.contains(point) {
            absorbSynthoidNode(at: point)
        } else if grid.treePositions.contains(point) {
            absorbTreeNode(at: point)
        } else {
            nodeManipulator.absorbRock(at: point, animated: animated, completion: completion)
            grid.removeRock(at: point)
        }
    }

    func absorbSynthoidNode(at point: GridPoint, animated: Bool = false, completion: (() -> Void)? = nil) {
        guard let index = grid.synthoidPositions.firstIndex(of: point) else { return }

        nodeManipulator.absorbSynthoid(at: point, animated: animated, completion: completion)
        grid.synthoidPositions.remove(at: index)
    }

    func absorbSentryNode(at point: GridPoint, animated: Bool = false) {
        guard let index = grid.sentryPositions.firstIndex(of: point) else { return }

        nodeManipulator.absorbSentry(at: point, animated: animated)
        grid.sentryPositions.remove(at: index)
    }

    func absorbSentinelNode(at point: GridPoint, animated: Bool = false) {
        nodeManipulator.absorbSentinel(at: point, animated: false)
    }
}
