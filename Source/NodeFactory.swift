import GLKit
import SceneKit

let ambientLightNodeName = "ambientLightNodeName"

let radiansInCircle = Float.pi * 2.0

let interactiveNodeBitMask = 2
let noninteractiveTransparentNodeBitMask = 4
let noninteractiveBlockingNodeBitMask = 8

enum NodeFactoryOption: Equatable {
    case showDetectionNode
    case showVisionNode(Bool)
}

class NodeFactory {
    let nodePositioning: NodePositioning

    private let options: [NodeFactoryOption]

    private let detectionNode: DetectionAreaNode
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
         materialFactory: MaterialFactory,
         options: [NodeFactoryOption] = []) {
        self.nodePositioning = nodePositioning
        self.options = options

        let floorSize = nodePositioning.floorSize

        detectionNode = DetectionAreaNode(detectionRadius: detectionRadius)
        cube1 = FloorNode(floorSize: floorSize, colour: materialFactory.floor1Colour)
        cube2 = FloorNode(floorSize: floorSize, colour: materialFactory.floor2Colour)
        slope1 = SlopeNode(floorSize: floorSize, colour: materialFactory.slope1Colour)
        slope2 = SlopeNode(floorSize: floorSize, colour: materialFactory.slope2Colour)
        sentinel = SentinelNode(floorSize: floorSize, detectionRadius: detectionRadius, options: options)
        sentry = SentryNode(floorSize: floorSize, detectionRadius: detectionRadius, options: options)
        synthoid = SynthoidNode(floorSize: floorSize)
        tree = TreeNode(floorSize: floorSize)
        rock = RockNode(floorSize: floorSize)
    }

    func createCameraNode() -> SCNNode {
        return CameraNode(zFar: nil)
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
                guard let gridPiece = grid.get(point: GridPoint(x: x, z: z)) else { continue }
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

        addWallNodes(to: terrainNode, grid: grid)
        addSentinelNode(grid: grid, nodeMap: nodeMap)
        addSentryNodes(grid: grid, nodeMap: nodeMap)
        addSynthoidNode(grid: grid, nodeMap: nodeMap)
        addTreeNodes(grid: grid, nodeMap: nodeMap)

        return terrainNode
    }

    private func createSentinelNode(initialAngle: Float) -> SentinelNode {
        let clone = sentinel.clone()
        clone.position = nodePositioning.calculateObjectPosition()
        clone.rotation = SCNVector4Make(0.0, 1.0, 0.0, initialAngle)
        addDetectionNode(to: clone)
        addBlurFilter(to: clone)
        return clone
    }

    private func createSentryNode(initialAngle: Float) -> SentryNode {
        let clone = sentry.clone()
        clone.position = nodePositioning.calculateObjectPosition()
        clone.rotation = SCNVector4Make(0.0, 1.0, 0.0, initialAngle)
        addDetectionNode(to: clone)
        addBlurFilter(to: clone)
        return clone
    }

    private func addDetectionNode(to node: SCNNode) {
        guard options.contains(.showDetectionNode) else {
            return
        }

        let clone = detectionNode.clone()
        node.addChildNode(clone)
    }

    private func addBlurFilter(to node: SCNNode) {
        guard options.contains(.showVisionNode(true)) else {
            return
        }

        if let visionNode = node.childNode(withName: visionNodeName, recursively: true),
            let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur") {
            visionNode.filters = [gaussianBlurFilter]
        }
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
            w = radiansInCircle * Float(drand48())
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

    private func addSentinelNode(grid: Grid, nodeMap: NodeMap) {
        if grid.get(point: grid.sentinelPosition) != nil, let floorNode = nodeMap.getFloorNode(for: grid.sentinelPosition) {
            var initialAngle = grid.startPosition.angle(to: grid.sentinelPosition)
            if initialAngle > radiansInCircle {
                initialAngle -= radiansInCircle
            }

            let rightAngle = initialAngle.closestRightAngle
            floorNode.sentinelNode = createSentinelNode(initialAngle: rightAngle)
        }
    }

    private func addSentryNodes(grid: Grid, nodeMap: NodeMap) {
        for sentryPosition in grid.sentryPositions {
            if grid.get(point: sentryPosition) != nil, let floorNode = nodeMap.getFloorNode(for: sentryPosition) {
                var initialAngle = grid.startPosition.angle(to: sentryPosition)
                if initialAngle > radiansInCircle {
                    initialAngle -= radiansInCircle
                }

                let rightAngle = initialAngle.closestRightAngle
                floorNode.sentryNode = createSentryNode(initialAngle: rightAngle)
            }
        }
    }

    private func addSynthoidNode(grid: Grid, nodeMap: NodeMap) {
        if grid.get(point: grid.startPosition) != nil, let floorNode = nodeMap.getFloorNode(for: grid.startPosition) {
            let angleToSentinel = grid.startPosition.angle(to: grid.sentinelPosition)
            floorNode.synthoidNode = createSynthoidNode(height: 0, viewingAngle: angleToSentinel)
        }
    }

    private func addTreeNodes(grid: Grid, nodeMap: NodeMap) {
        for treePosition in grid.treePositions {
            if grid.get(point: treePosition) != nil, let floorNode = nodeMap.getFloorNode(for: treePosition) {
                floorNode.treeNode = createTreeNode(height: 0)
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
        var closest = radiansInCircle
        var smallestDelta = radiansInCircle
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
