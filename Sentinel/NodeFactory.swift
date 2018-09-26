import GLKit
import SceneKit

let cameraNodeName = "cameraNodeName"
let terrainNodeName = "terrainNodeName"
let floorNodeName = "floorNodeName"
let slopeNodeName = "slopeNodeName"
let sentinelNodeName = "sentinelNodeName"
let sentryNodeName = "sentryNodeName"
let synthoidNodeName = "synthoidNodeName"
let treeNodeName = "treeNodeName"
let rockNodeName = "rockNodeName"
let ambientLightNodeName = "ambientLightNodeName"

fileprivate let radiansInCircle = Float.pi * 2.0

enum InteractiveNodeType: Int, CaseIterable {
    case floor = 2
    case tree = 4
    case rock = 8
    case synthoid = 16
    case sentry = 32
    case sentinel = 64
}

class NodeFactory: NSObject {
    let nodePositioning: NodePositioning

    private let detectionNode: DetectionAreaNode

    private let cube1: FloorNode
    private let cube2: FloorNode
    private let slope: SlopeNode

    private let sentinel: SentinelNode
    private let sentry: SentryNode

    private let synthoid: SynthoidNode
    private let tree: TreeNode
    private let rock: RockNode

    init(nodePositioning: NodePositioning, detectionRadius: Float) {
        self.nodePositioning = nodePositioning

        let floorSize = nodePositioning.floorSize

        detectionNode = DetectionAreaNode(detectionRadius: detectionRadius)
        cube1 = FloorNode(floorSize: floorSize, colour: .red)
        cube2 = FloorNode(floorSize: floorSize, colour: .yellow)
        slope = SlopeNode(floorSize: floorSize)
        sentinel = SentinelNode(floorSize: floorSize, detectionRadius: detectionRadius)
        sentry = SentryNode(floorSize: floorSize, detectionRadius: detectionRadius)
        synthoid = SynthoidNode(floorSize: floorSize)
        tree = TreeNode(floorSize: floorSize)
        rock = RockNode(floorSize: floorSize)

        super.init()
    }

    func createCameraNode() -> SCNNode {
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true
        let cameraNode = SCNNode()
        cameraNode.name = cameraNodeName
        cameraNode.camera = camera
        return cameraNode
    }

    func createAmbientLightNodes(distance: Float) -> [SCNNode] {
        var ambientLightNodes: [SCNNode] = []
        var ambientLightNode = createAmbientLightNode()
        for x in -1 ... 1 {
            for z in -1 ... 1 {
                if abs(x + z) == 1 {
                    continue
                }

                let xf = Float(x) * distance
                let yf = distance
                let zf = Float(z) * distance
                ambientLightNode.position = SCNVector3Make(xf, yf, zf)
                ambientLightNodes.append(ambientLightNode)

                ambientLightNode = ambientLightNode.clone()
            }
        }
        return ambientLightNodes
    }

    func createAmbientLightNode() -> SCNNode {
        let ambient = SCNLight()
        ambient.type = .omni
        ambient.color = UIColor(red: 0.21, green: 0.17, blue: 0.17, alpha: 1.0)
        let ambientNode = SCNNode()
        ambientNode.name = ambientLightNodeName
        ambientNode.light = ambient
        return ambientNode
    }

    func createTerrainNode(grid: Grid, nodeMap: NodeMap) -> TerrainNode {
        let terrainNode = TerrainNode()

        let width = grid.width
        let depth = grid.depth

        for z in 0 ..< depth {
            for x in 0 ..< width {
                if let gridPiece = grid.get(point: GridPoint(x: x, z: z)) {
                    if gridPiece.isFloor {
                        let node = createFloorNode(x: x,
                                                   y: Int(gridPiece.level - 1.0),
                                                   z: z)
                        terrainNode.addChildNode(node)
                        nodeMap.add(floorNode: node, for: gridPiece)
                    } else {
                        for direction in GridDirection.allCases {
                            if gridPiece.has(slopeDirection: direction) {
                                let node = createSlopeNode(x: x,
                                                           y: Int(gridPiece.level - 0.5),
                                                           z: z,
                                                           rotation: rotation(for: direction))
                                terrainNode.addChildNode(node)
                            }
                        }
                    }
                }
            }
        }

        addWallNodes(to: terrainNode, grid: grid)

        if let _ = grid.get(point: grid.sentinelPosition), let floorNode = nodeMap.getFloorNode(for: grid.sentinelPosition) {
            var initialAngle = grid.startPosition.angle(to: grid.sentinelPosition) + Float.pi
            if initialAngle > radiansInCircle {
                initialAngle -= radiansInCircle
            }

            let rightAngle = closestRightAngle(to: initialAngle)
            floorNode.sentinelNode = createSentinelNode(initialAngle: rightAngle)
        }

        for sentryPosition in grid.sentryPositions {
            if let _ = grid.get(point: sentryPosition), let floorNode = nodeMap.getFloorNode(for: sentryPosition) {
                var initialAngle = grid.startPosition.angle(to: sentryPosition) + Float.pi
                if initialAngle > radiansInCircle {
                    initialAngle -= radiansInCircle
                }

                let rightAngle = closestRightAngle(to: initialAngle)
                floorNode.sentryNode = createSentryNode(initialAngle: rightAngle)
            }
        }

        if let _ = grid.get(point: grid.startPosition), let floorNode = nodeMap.getFloorNode(for: grid.startPosition) {
            let angleToSentinel = grid.startPosition.angle(to: grid.sentinelPosition)
            floorNode.synthoidNode = createSynthoidNode(height: 0, viewingAngle: angleToSentinel)
        }

        for treePosition in grid.treePositions {
            if let _ = grid.get(point: treePosition), let floorNode = nodeMap.getFloorNode(for: treePosition) {
                floorNode.treeNode = createTreeNode(height: 0)
            }
        }

        return terrainNode
    }

    private func closestRightAngle(to angle: Float) -> Float {
        var closest = radiansInCircle
        var smallestDelta = radiansInCircle
        for i in 1 ... 4 {
            let candidate = Float.pi / 2.0 * Float(i)
            let delta = fabsf(candidate - angle)
            if delta < smallestDelta {
                closest = candidate
                smallestDelta = delta
            }
        }
        return closest
    }

    func createSentinelNode(initialAngle: Float) -> SentinelNode {
        let clone = sentinel.clone()
        clone.position = nodePositioning.calculateObjectPosition()
        clone.rotation = SCNVector4Make(0.0, 1.0, 0.0, initialAngle)
        return clone
    }

    func createSentryNode(initialAngle: Float) -> SentryNode {
        let clone = sentry.clone()
        clone.position = nodePositioning.calculateObjectPosition()
        clone.rotation = SCNVector4Make(0.0, 1.0, 0.0, initialAngle)
        return clone
    }

    func createSynthoidNode(height: Int, viewingAngle: Float) -> SynthoidNode {
        let clone = synthoid.clone()
        clone.position = nodePositioning.calculateObjectPosition(height: height)
        clone.viewingAngle = viewingAngle
        return clone
    }

    func createTreeNode(height: Int) -> TreeNode {
        let clone = tree.clone()
        clone.position = nodePositioning.calculateObjectPosition(height: height)
        return clone
    }

    func createRockNode(height: Int) -> RockNode {
        let clone = rock.clone()
        clone.position = nodePositioning.calculateObjectPosition(height: height)
        let rotation = radiansInCircle * Float(drand48())
        clone.rotation = SCNVector4Make(0.0, 1.0, 0.0, rotation)
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
        if let gridPiece = grid.get(point: GridPoint(x: x, z: z)) {
            var height = gridPiece.level
            if !gridPiece.isFloor {
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
        let source = (x + z + y) % 2 == 0 ? cube1 : cube2
        let boxNode = source.clone()
        boxNode.position = nodePositioning.calculateTerrainPosition(x: x, y: Float(y), z: z)
        return boxNode
    }

    private func createSlopeNode(x: Int, y: Int, z: Int, rotation: SCNVector4? = nil) -> SlopeNode {
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
