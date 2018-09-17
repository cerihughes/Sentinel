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
let sunNodeName = "sunNodeName"
let ambientLightNodeName = "ambientLightNodeName"

enum interactiveNodeType: Int {
    case floor = 2
    case tree = 4
    case rock = 8
    case synthoid = 16
    case sentry = 32
    case sentinel = 64

    // TODO: Replace when Swift 4.2 is out of beta
    static func allValues() -> [interactiveNodeType] {
        return [.floor, .tree, .rock, .synthoid, .sentry, .sentinel]
    }
}

class NodeFactory: NSObject {
    let nodePositioning: NodePositioning

    private let cube1: FloorNode
    private let cube2: FloorNode
    private let slope: SlopeNode

    private let sentinel: SentinelNode
    private let sentry: SentryNode

    private let synthoid: SynthoidNode
    private let tree: TreeNode
    private let rock: RockNode

    init(nodePositioning: NodePositioning) {
        self.nodePositioning = nodePositioning

        let floorSize = nodePositioning.floorSize

        cube1 = FloorNode(floorSize: floorSize, colour: .red)
        cube2 = FloorNode(floorSize: floorSize, colour: .yellow)
        slope = SlopeNode(floorSize: floorSize)
        sentinel = SentinelNode(floorSize: floorSize)
        sentry = SentryNode(floorSize: floorSize)
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

    func createSunNode() -> SCNNode {
        let sun = SCNLight()
        sun.type = .spot
        sun.color = UIColor(white: 0.9, alpha: 1.0)
        sun.castsShadow = true
        sun.shadowRadius = 50.0
        sun.shadowColor = UIColor(white: 0.0, alpha: 0.75)
        sun.zNear = 300.0
        sun.zFar = 700.0
        sun.attenuationStartDistance = 300.0
        sun.attenuationEndDistance = 700.0
        let sunNode = SCNNode()
        sunNode.name = sunNodeName
        sunNode.light = sun
        return sunNode
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
                        for direction in GridDirection.allValues() {
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
            floorNode.sentinelNode = createSentinelNode()
        }

        for sentryPosition in grid.sentryPositions {
            if let _ = grid.get(point: sentryPosition), let floorNode = nodeMap.getFloorNode(for: sentryPosition) {
                floorNode.sentryNode = createSentryNode()
            }
        }

        if let _ = grid.get(point: grid.startPosition), let floorNode = nodeMap.getFloorNode(for: grid.startPosition) {
            floorNode.synthoidNode = createSynthoidNode(rockCount: 0)
        }

        for treePosition in grid.treePositions {
            if let _ = grid.get(point: treePosition), let floorNode = nodeMap.getFloorNode(for: treePosition) {
                floorNode.treeNode = createTreeNode(rockCount: 0)
            }
        }

        return terrainNode
    }

    func createSentinelNode(startAngle: Float = 0.0) -> SentinelNode {
        let clone = sentinel.clone()
        clone.position = nodePositioning.calculateObjectPosition()
        clone.rotation = SCNVector4Make(0.0, 1.0, 0.0, startAngle)
        return clone
    }

    func createSentryNode(startAngle: Float = 0.0) -> SentryNode {
        let clone = sentry.clone()
        clone.position = nodePositioning.calculateObjectPosition()
        clone.rotation = SCNVector4Make(0.0, 1.0, 0.0, startAngle)
        return clone
    }

    func createSynthoidNode(rockCount: Int) -> SynthoidNode {
        let clone = synthoid.clone()
        clone.position = nodePositioning.calculateObjectPosition()
        clone.position.y += Float(rockCount) * 0.5 * nodePositioning.floorSize
        return clone
    }

    func createTreeNode(rockCount: Int) -> TreeNode {
        let clone = tree.clone()
        clone.position = nodePositioning.calculateObjectPosition()
        clone.position.y += Float(rockCount) * 0.5 * nodePositioning.floorSize
        return clone
    }

    func createRockNode(rockCount: Int) -> RockNode {
        let clone = rock.clone()
        clone.position = nodePositioning.calculateObjectPosition()
        clone.position.y += Float(rockCount) * 0.5 * nodePositioning.floorSize
        let rotation = Float.pi * 2.0 * Float(drand48())
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
