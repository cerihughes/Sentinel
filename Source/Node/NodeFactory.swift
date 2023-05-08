import GLKit
import SceneKit

let ambientLightNodeName = "ambientLightNodeName"

let interactiveNodeBitMask = 2
let noninteractiveTransparentNodeBitMask = 4
let noninteractiveBlockingNodeBitMask = 8

class NodeFactory {
    let nodePositioning: NodePositioning

    private let cube1: FloorNode
    private let cube2: FloorNode
    private let slope1: SlopeNode
    private let slope2: SlopeNode
    private let sentinel: SentinelNode
    private let sentry: SentryNode
    private let synthoid: SynthoidNode
    private let tree: TreeNode
    private let rock: RockNode

    init(nodePositioning: NodePositioning,
         detectionRadius: Float,
         materialFactory: MaterialFactory) {
        self.nodePositioning = nodePositioning

        cube1 = FloorNode(colour: materialFactory.floor1Colour)
        cube2 = FloorNode(colour: materialFactory.floor2Colour)
        slope1 = SlopeNode(colour: materialFactory.slope1Colour)
        slope2 = SlopeNode(colour: materialFactory.slope2Colour)
        sentinel = SentinelNode(detectionRadius: detectionRadius)
        sentry = SentryNode(detectionRadius: detectionRadius)
        synthoid = SynthoidNode()
        tree = TreeNode()
        rock = RockNode()
    }

    func createCameraNode() -> SCNNode {
        return CameraNode(zFar: nil)
    }

    func createTerrainNode(grid: Grid, nodeMap: NodeMap) -> TerrainNode {
        let terrainNode = TerrainNode()

        let width = grid.width
        let depth = grid.depth

        for z in 0 ..< depth {
            for x in 0 ..< width {
                guard let piece = grid.piece(at: GridPoint(x: x, z: z)) else { continue }
                if piece.isFloor {
                    let node = createFloorNode(x: x, y: Int(piece.level - 1.0), z: z)
                    terrainNode.addChildNode(node)
                    nodeMap.add(floorNode: node, for: piece)
                } else {
                    for direction in GridDirection.allCases where piece.has(slopeDirection: direction) {
                        let rotation = rotation(for: direction)
                        let node = createSlopeNode( x: x, y: Int(piece.level - 0.5), z: z, rotation: rotation)
                        terrainNode.addChildNode(node)
                    }
                }
            }
        }

        addWallNodes(to: terrainNode, grid: grid)
        addSentinelNode(grid: grid, nodeMap: nodeMap)
        addSentryNodes(grid: grid, nodeMap: nodeMap)
        addSynthoidNode(grid: grid, nodeMap: nodeMap)
        addTreeNodes(grid: grid, nodeMap: nodeMap)
        addRockNodes(grid: grid, nodeMap: nodeMap)

        return terrainNode
    }

    private func createSentinelNode(initialAngle: Float) -> SentinelNode {
        let clone = sentinel.clone()
        clone.position = nodePositioning.calculateObjectPosition()
        clone.rotation = SCNVector4Make(0.0, 1.0, 0.0, initialAngle)
        return clone
    }

    private func createSentryNode(initialAngle: Float) -> SentryNode {
        let clone = sentry.clone()
        clone.position = nodePositioning.calculateObjectPosition()
        clone.rotation = SCNVector4Make(0.0, 1.0, 0.0, initialAngle)
        return clone
    }

    func createSynthoidNode(height: Int, viewingAngle: Float) -> SynthoidNode {
        let clone = synthoid.clone()
        clone.position = nodePositioning.calculateObjectPosition(height: height)
        clone.apply(rotationDelta: viewingAngle, elevationDelta: 0.0, persist: true)
        return clone
    }

    func createTreeNode(height: Int) -> TreeNode {
        let clone = tree.clone()
        clone.position = nodePositioning.calculateObjectPosition(height: height)
        return clone
    }

    func createRockNode(height: Int, rotation: Float? = nil) -> RockNode {
        let clone = rock.clone()
        clone.position = nodePositioning.calculateObjectPosition(height: height)
        let w: Float
        if let rotation = rotation {
            w = rotation
        } else {
            w = .radiansInCircle * Float.random(in: 0.0..<1.0)
        }

        clone.rotation = SCNVector4Make(0.0, 1.0, 0.0, w)
        return clone
    }

    private func addWallNodes(to terrainNode: SCNNode, grid: Grid) {
        for x in 0 ..< grid.width {
            addWallNodes(to: terrainNode, grid: grid, x: x, z: 0)
            addWallNodes(to: terrainNode, grid: grid, x: x, z: grid.depth - 1)
        }
        for z in 0 ..< grid.depth {
            addWallNodes(to: terrainNode, grid: grid, x: 0, z: z)
            addWallNodes(to: terrainNode, grid: grid, x: grid.width - 1, z: z)
        }
    }

    private func addWallNodes(to terrainNode: SCNNode, grid: Grid, x: Int, z: Int) {
        if let piece = grid.piece(at: GridPoint(x: x, z: z)) {
            var height = piece.level
            if !piece.isFloor {
                height += 0.5
            }

            if height <= 0 {
                return
            }
            let wallNodes = createWallNodes(x: x, z: z, height: Int(height))
            for wallNode in wallNodes {
                terrainNode.addChildNode(wallNode)
            }
        }
    }

    private func addSentinelNode(grid: Grid, nodeMap: NodeMap) {
        if grid.piece(at: grid.sentinelPosition) != nil,
            let floorNode = nodeMap.getFloorNode(for: grid.sentinelPosition) {
            let initialAngle = min(grid.startPosition.angle(to: grid.sentinelPosition), .radiansInCircle)
            let rightAngle = initialAngle.closestRightAngle
            floorNode.sentinelNode = createSentinelNode(initialAngle: rightAngle)
        }
    }

    private func addSentryNodes(grid: Grid, nodeMap: NodeMap) {
        for sentryPosition in grid.sentryPositions {
            if grid.piece(at: sentryPosition) != nil, let floorNode = nodeMap.getFloorNode(for: sentryPosition) {
                let initialAngle = min(grid.startPosition.angle(to: sentryPosition), .radiansInCircle)
                let rightAngle = initialAngle.closestRightAngle
                floorNode.sentryNode = createSentryNode(initialAngle: rightAngle)
            }
        }
    }

    private func addSynthoidNode(grid: Grid, nodeMap: NodeMap) {
        if grid.piece(at: grid.startPosition) != nil, let floorNode = nodeMap.getFloorNode(for: grid.startPosition) {
            let angleToSentinel = grid.startPosition.angle(to: grid.sentinelPosition)
            floorNode.synthoidNode = createSynthoidNode(height: 0, viewingAngle: angleToSentinel)
        }
    }

    private func addTreeNodes(grid: Grid, nodeMap: NodeMap) {
        for treePosition in grid.treePositions {
            if grid.piece(at: treePosition) != nil, let floorNode = nodeMap.getFloorNode(for: treePosition) {
                floorNode.treeNode = createTreeNode(height: grid.rockCount(at: treePosition))
            }
        }
    }

    private func addRockNodes(grid: Grid, nodeMap: NodeMap) {
        for rockPosition in grid.allRockPositions() {
            if grid.piece(at: rockPosition) != nil, let floorNode = nodeMap.getFloorNode(for: rockPosition) {
                for height in 0 ..< grid.rockCount(at: rockPosition) {
                    floorNode.add(rockNode: createRockNode(height: height))
                }
            }
        }
    }

    private func rotation(for direction: GridDirection) -> SCNVector4? {
        switch direction {
        case .north:
            return SCNVector4Make(0.0, 1.0, 0.0, Float.pi / 2.0)
        case .east:
            return nil
        case .south:
            return SCNVector4Make(0.0, 1.0, 0.0, Float.pi / -2.0)
        case .west:
            return SCNVector4Make(0.0, 1.0, 0.0, Float.pi)
        }
    }

    private func createFloorNode(x: Int, y: Int, z: Int) -> FloorNode {
        let cube = (x + z + y) % 2 == 0 ? cube1 : cube2
        let clone = cube.clone()
        clone.position = nodePositioning.calculateTerrainPosition(x: x, y: Float(y), z: z)
        return clone
    }

    private func createSlopeNode(x: Int, y: Int, z: Int, rotation: SCNVector4? = nil) -> SlopeNode {
        let slope = (x + z + y) % 2 == 0 ? slope1 : slope2
        let clone = slope.clone()
        clone.position = nodePositioning.calculateTerrainPosition(x: x, y: Float(y), z: z)
        if let rotation = rotation {
            clone.rotation = rotation
        }
        return clone
    }

    private func createWallNodes(x: Int, z: Int, height: Int) -> [FloorNode] {
        var wallNodes: [FloorNode] = []
        for y in 0 ..< height {
            let wallNode = createFloorNode(x: x, y: y - 1, z: z)
            wallNodes.append(wallNode)
        }
        return wallNodes
    }
}

private extension Float {
    var closestRightAngle: Float {
        var closest = Float.radiansInCircle
        var smallestDelta = Float.radiansInCircle
        for i in 1 ... 4 {
            let candidate = Float.pi / 2.0 * Float(i)
            let delta = fabsf(candidate - self)
            if delta < smallestDelta {
                closest = candidate
                smallestDelta = delta
            }
        }
        return closest
    }
}

extension Float {
    static let floorSize = Float(10.0)
    static let radiansInCircle = Float.pi * 2.0
}

extension CGFloat {
    static let floorSize = CGFloat(Float.floorSize)
    static let radiansInCircle = CGFloat(Float.radiansInCircle)
}
