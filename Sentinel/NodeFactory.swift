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

enum InteractableNodeType: Int {
    case floor = 2
    case tree = 4
    case rock = 8
    case synthoid = 16
    case sentry = 32
    case sentinel = 64

    // TODO: Replace when Swift 4.2 is out of beta
    static func allValues() -> [InteractableNodeType] {
        return [.floor, .tree, .rock, .synthoid, .sentry, .sentinel]
    }
}

class NodeFactory: NSObject {
    let nodePositioning: NodePositioning

    private let prototypes: NodePrototypes

    private let cube1: SCNNode
    private let cube2: SCNNode
    private let wedge: SCNNode

    private let sentinel: SCNNode
    private let sentry: SCNNode
    private let synthoid: SCNNode
    private let tree: SCNNode
    private let rock: SCNNode

    init(nodePositioning: NodePositioning) {
        self.nodePositioning = nodePositioning

        let sideLength = nodePositioning.sideLength
        self.prototypes = NodePrototypes(sideLength: sideLength)

        cube1 = prototypes.createCube(colour: .red)
        cube2 = prototypes.createCube(colour: .yellow)
        wedge = prototypes.createWedge()
        sentinel = prototypes.createSentinel()
        sentry = prototypes.createSentry()
        synthoid = prototypes.createSynthoid()
        tree = prototypes.createTree()
        rock = prototypes.createRock()

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

    func createTerrainNode(grid: Grid, nodeMap: NodeMap) -> SCNNode {
        let terrainNode = SCNNode()
        terrainNode.name = terrainNodeName

        let width = grid.width
        let depth = grid.depth

        for z in 0 ..< depth {
            for x in 0 ..< width {
                if let gridPiece = grid.get(point: GridPoint(x: x, z: z)) {
                    if gridPiece.isFloor {
                        let node = createFloorPiece(x: x,
                                                   y: Int(gridPiece.level - 1.0),
                                                   z: z)
                        terrainNode.addChildNode(node)
                        nodeMap.add(node: node, for: gridPiece)
                    } else {
                        for direction in GridDirection.allValues() {
                            if gridPiece.has(slopeDirection: direction) {
                                let node = createWedgePiece(x: x,
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

        if let _ = grid.get(point: grid.sentinelPosition), let floorNode = nodeMap.getNode(for: grid.sentinelPosition) {
            let sentinelNode = createSentinelNode()
            floorNode.addChildNode(sentinelNode)
        }

        for sentryPosition in grid.sentryPositions {
            if let _ = grid.get(point: sentryPosition), let floorNode = nodeMap.getNode(for: sentryPosition) {
                let sentryNode = createSentryNode()
                floorNode.addChildNode(sentryNode)
            }
        }

        if let _ = grid.get(point: grid.startPosition), let floorNode = nodeMap.getNode(for: grid.startPosition) {
            let synthoidNode = createSynthoidNode()
            floorNode.addChildNode(synthoidNode)
        }

        for treePosition in grid.treePositions {
            if let _ = grid.get(point: treePosition), let floorNode = nodeMap.getNode(for: treePosition) {
                let treeNode = createTreeNode()
                floorNode.addChildNode(treeNode)
            }
        }

        return terrainNode
    }

    func createSentinelNode(startAngle: Float = 0.0, rotationTime: TimeInterval = 30.0) -> SCNNode {
        let clone = sentinel.clone()
        clone.position = nodePositioning.calculateObjectPosition()
        clone.rotation = SCNVector4Make(0.0, 1.0, 0.0, startAngle)
        clone.addAnimation(createRotationAnimation(rotationTime: rotationTime), forKey: "rotate")
        return clone
    }

    func createSentryNode(startAngle: Float = 0.0, rotationTime: TimeInterval = 30.0) -> SCNNode {
        let clone = sentry.clone()
        clone.position = nodePositioning.calculateObjectPosition()
        clone.rotation = SCNVector4Make(0.0, 1.0, 0.0, startAngle)
        clone.addAnimation(createRotationAnimation(rotationTime: rotationTime), forKey: "rotate")
        return clone
    }

    private func createRotationAnimation(rotationTime: TimeInterval) -> CABasicAnimation {
        let rotate = CABasicAnimation(keyPath: "rotation.w")
        rotate.byValue = Float.pi * -2.0
        rotate.duration = rotationTime
        rotate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        rotate.repeatCount = Float.infinity
        return rotate
    }

    func createSynthoidNode(index: Int = 0) -> SCNNode {
        let clone = synthoid.clone()
        clone.position = nodePositioning.calculateObjectPosition()
        clone.position.y += Float(index) * 0.5 * nodePositioning.sideLength
        return clone
    }

    func createTreeNode() -> SCNNode {
        let clone = tree.clone()
        clone.position = nodePositioning.calculateObjectPosition()
        return clone
    }

    func createRockNode(index: Int = 0) -> SCNNode {
        let clone = rock.clone()
        clone.position = nodePositioning.calculateObjectPosition()
        clone.position.y += Float(index) * 0.5 * nodePositioning.sideLength
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
            let wallNodes = createWallPiece(x: x, z: z, height: Int(height))
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

    private func createFloorPiece(x: Int, y: Int, z: Int) -> SCNNode {
        let source = (x + z + y) % 2 == 0 ? cube1 : cube2
        let boxNode = source.clone()
        boxNode.position = nodePositioning.calculateTerrainPosition(x: x, y: Float(y), z: z)
        return boxNode
    }

    private func createWedgePiece(x: Int, y: Int, z: Int, rotation: SCNVector4? = nil) -> SCNNode {
        let clone = wedge.clone()
        clone.position = nodePositioning.calculateTerrainPosition(x: x, y: Float(y), z: z)
        if let rotation = rotation {
            clone.rotation = rotation
        }
        return clone
    }

    private func createWallPiece(x: Int, z: Int, height: Int) -> [SCNNode] {
        var wallNodes: [SCNNode] = []
        for y in 0 ..< height {
            let wallNode = createFloorPiece(x: x, y: y - 1, z: z)
            wallNodes.append(wallNode)
        }
        return wallNodes
    }
}

fileprivate class NodePrototypes: NSObject {
    let sideLength: Float

    let geometryFactory: GeometryFactory

    init(sideLength: Float) {
        self.sideLength = sideLength
        geometryFactory = GeometryFactory(size: sideLength)

        super.init()
    }

    func createCube(colour: UIColor) -> SCNNode {
        let cube = geometryFactory.createCube(colour: colour)
        let cubeNode = SCNNode(geometry: cube)
        cubeNode.name = floorNodeName
        cubeNode.categoryBitMask = InteractableNodeType.floor.rawValue
        return cubeNode
    }

    func createWedge() -> SCNNode {
        let wedge = geometryFactory.createWedge(colour: .darkGray)
        let wedgeNode = SCNNode(geometry: wedge)
        wedgeNode.name = slopeNodeName
        return wedgeNode
    }

    func createSentinel() -> SCNNode {
        let sentinelNode = createOpposition(colour: .blue)
        sentinelNode.name = sentinelNodeName
        sentinelNode.categoryBitMask = InteractableNodeType.sentinel.rawValue
        return sentinelNode
    }

    func createSentry() -> SCNNode {
        let sentryNode = createOpposition(colour: .green)
        sentryNode.name = sentryNodeName
        sentryNode.categoryBitMask = InteractableNodeType.sentry.rawValue
        return sentryNode
    }

    func createOpposition(colour: UIColor) -> SCNNode {
        let oppositionNode = SCNNode()

        var material = SCNMaterial()
        material.diffuse.contents = colour

        let segments = 3
        var y: Float = 0.0
        for i in 0 ..< segments {
            let fi = Float(i)
            let radius = (sideLength / 2.0) - fi
            let sphere = SCNSphere(radius: CGFloat(radius))
            sphere.firstMaterial = material
            let sphereNode = SCNNode(geometry: sphere)
            y += radius
            sphereNode.position.y = y
            y += 5.0 / Float(segments - 1)
            oppositionNode.addChildNode(sphereNode)
        }

        material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        let width = CGFloat(sideLength / 3.0)
        let height = CGFloat(sideLength / 10.0)
        let box = SCNBox(width: width, height: height, length: height, chamferRadius: 0.2)
        box.firstMaterial = material
        let boxNode = SCNNode(geometry: box)
        boxNode.position.z = sideLength / 5.0
        boxNode.position.y = y
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true
        let cameraNode = SCNNode()
        cameraNode.name = cameraNodeName
        cameraNode.camera = camera
        cameraNode.rotation = SCNVector4Make(0.0, 1.0, 0.25, Float.pi)

        boxNode.addChildNode(cameraNode)
        oppositionNode.addChildNode(boxNode)

        return oppositionNode
    }

    func createSynthoid() -> SCNNode {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.purple
        let capsule = SCNCapsule(capRadius: CGFloat(sideLength / 3.0), height: CGFloat(sideLength))
        capsule.firstMaterial = material
        let synthoidNode = SCNNode(geometry: capsule)
        synthoidNode.name = synthoidNodeName
        synthoidNode.categoryBitMask = InteractableNodeType.synthoid.rawValue
        synthoidNode.pivot = SCNMatrix4MakeTranslation(0.0, -0.5 * sideLength, 0.0)

        return synthoidNode
    }

    func createTree() -> SCNNode {
        let width = CGFloat(sideLength)
        let height = width * 1.5
        let maxRadius = width / 3.0

        let trunkHeight: CGFloat = height * 3.0 / 10.0
        let trunkRadius: CGFloat = maxRadius * 0.2

        let treeNode = SCNNode()
        treeNode.name = treeNodeName
        treeNode.categoryBitMask = InteractableNodeType.tree.rawValue

        let trunkNode = SCNNode(geometry: SCNCylinder(radius: trunkRadius, height: trunkHeight))
        trunkNode.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
        trunkNode.position.y = Float(trunkHeight / 2.0)
        treeNode.addChildNode(trunkNode)

        let initialLeafRadius = maxRadius
        let leafHeight: CGFloat = height - trunkHeight
        let numberOfLevels = 4
        let sectionHeight = leafHeight / CGFloat(numberOfLevels)
        var y = Float(trunkHeight + (sectionHeight / 2.0))

        let radiusDelta = initialLeafRadius / CGFloat(numberOfLevels + 1)
        for i in 0 ..< numberOfLevels {
            let bottomRadius = initialLeafRadius - (radiusDelta * CGFloat(i))
            let topRadius = bottomRadius - (radiusDelta * 2.0)
            let leavesNode = SCNNode(geometry: SCNCone(topRadius: topRadius, bottomRadius: bottomRadius, height: sectionHeight))
            leavesNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
            leavesNode.position.y = y

            y += Float(sectionHeight)

            treeNode.addChildNode(leavesNode)
        }

        return treeNode
    }

    func createRock() -> SCNNode {
        let rockNode = SCNNode()
        let height = sideLength / 2.0

        let section = geometryFactory.createRockSegment(colour: .darkGray, extrusionDepth: sideLength / 3.0)
        var sectionNode = SCNNode(geometry: section)
        sectionNode.position = SCNVector3Make(0, 0, height / 6.0)
        sectionNode.rotation = SCNVector4Make(0.0, 0.0, 1.0, Float.pi / 1.14)
        rockNode.addChildNode(sectionNode)

        sectionNode = sectionNode.clone()
        sectionNode.position = SCNVector3Make(0, 0, height / 6.0 * 2.0)
        sectionNode.rotation = SCNVector4Make(0.2, 0.4, 0.4, -0.28)
        rockNode.addChildNode(sectionNode)

        sectionNode = sectionNode.clone()
        sectionNode.position = SCNVector3Make(0, 0, height / 6.0 * 3.0)
        sectionNode.rotation = SCNVector4Make(0.1, 0.1, 0.9, 0.18)
        rockNode.addChildNode(sectionNode)

        sectionNode = sectionNode.clone()
        sectionNode.position = SCNVector3Make(0, 0, height / 6.0 * 4.0)
        sectionNode.rotation = SCNVector4Make(0.6, 0.8, 0.0, -0.12)
        rockNode.addChildNode(sectionNode)

        sectionNode = sectionNode.clone()
        sectionNode.position = SCNVector3Make(0, 0, height / 6.0 * 5.0)
        sectionNode.rotation = SCNVector4Make(0.0, 0.0, 1.0, Float.pi / 1.54)
        rockNode.addChildNode(sectionNode)

        rockNode.rotation = SCNVector4Make(1.0, 0.0, 0.0, Float.pi / -2.0)

        let container = SCNNode()
        container.name = rockNodeName
        container.categoryBitMask = InteractableNodeType.rock.rawValue
        container.addChildNode(rockNode)

        return container
    }
}
