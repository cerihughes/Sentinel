import SceneKit
import SpriteKit

class TerrainOperations {
    var grid: Grid
    let nodeMap: NodeMap
    let nodeManipulator: NodeManipulator

    init(grid: Grid, nodeMap: NodeMap, nodeManipulator: NodeManipulator) {
        self.grid = grid
        self.nodeMap = nodeMap
        self.nodeManipulator = nodeManipulator
    }

    func buildTree(at point: GridPoint, animated: Bool = false, completion: (() -> Void)? = nil) {
        guard let floorNode = nodeMap.floorNode(at: point) else { return }
        let height = grid.rockCount(at: point)
        grid.treePositions.append(point)
        nodeManipulator.buildTree(on: floorNode, height: height, animated: animated, completion: completion)
    }

    func buildRock(
        at point: GridPoint,
        rotation: Float? = nil,
        animated: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        guard let floorNode = nodeMap.floorNode(at: point) else { return }
        let height = grid.rockCount(at: point)
        grid.addRock(at: point)
        nodeManipulator.buildRock(
            on: floorNode,
            height: height,
            rotation: rotation,
            animated: animated,
            completion: completion
        )
    }

    func buildSynthoid(at point: GridPoint, viewingAngle: Float) {
        guard let floorNode = nodeMap.floorNode(at: point) else { return }
        let height = grid.rockCount(at: point)
        grid.synthoidPositions.append(point)
        nodeManipulator.buildSynthoid(on: floorNode, height: height, viewingAngle: viewingAngle)
    }

    func absorbTreeNode(at point: GridPoint, animated: Bool = false, completion: (() -> Void)? = nil) {
        guard
            let floorNode = nodeMap.floorNode(at: point),
            let index = grid.treePositions.firstIndex(of: point)
        else {
            return
        }

        nodeManipulator.absorbTree(on: floorNode, animated: animated, completion: completion)
        grid.treePositions.remove(at: index)
    }

    func absorbRockNode(at point: GridPoint, animated: Bool = false, completion: (() -> Void)? = nil) {
        if grid.synthoidPositions.contains(point) {
            absorbSynthoidNode(at: point)
        } else if grid.treePositions.contains(point) {
            absorbTreeNode(at: point)
        } else {
            guard let floorNode = nodeMap.floorNode(at: point) else { return }
            nodeManipulator.absorbRock(on: floorNode, animated: animated, completion: completion)
            grid.removeRock(at: point)
        }
    }

    func absorbSynthoidNode(at point: GridPoint, animated: Bool = false, completion: (() -> Void)? = nil) {
        guard
            let floorNode = nodeMap.floorNode(at: point),
            let index = grid.synthoidPositions.firstIndex(of: point)
        else {
            return
        }

        nodeManipulator.absorbSynthoid(on: floorNode, animated: animated, completion: completion)
        grid.synthoidPositions.remove(at: index)
    }

    func absorbSentryNode(at point: GridPoint, animated: Bool = false) {
        guard
            let floorNode = nodeMap.floorNode(at: point),
            let index = grid.sentryPositions.firstIndex(of: point)
        else {
            return
        }

        nodeManipulator.absorbSentry(on: floorNode, animated: animated)
        grid.sentryPositions.remove(at: index)
    }

    func absorbSentinelNode(at point: GridPoint, animated: Bool = false) {
        guard let floorNode = nodeMap.floorNode(at: point) else { return }
        nodeManipulator.absorbSentinel(on: floorNode, animated: false)
    }
}
