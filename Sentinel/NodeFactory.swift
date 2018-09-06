import GLKit
import SceneKit

let cameraNodeName = "cameraNodeName"
let terrainNodeName = "terrainNodeName"
let flatNodeName = "flatNodeName"
let slopeNodeName = "slopeNodeName"
let sentinelNodeName = "sentinelNodeName"
let guardianNodeName = "guardianNodeName"
let playerNodeName = "playerNodeName"
let treeNodeName = "treeNodeName"

class NodeFactory: NSObject {
    let nodePositioning: NodePositioning

    let cube1: SCNNode
    let cube2: SCNNode
    let wedge: SCNNode

    let sentinel: SCNNode
    let guardian: SCNNode
    let player: SCNNode
    let tree: SCNNode

    var nodeMap: NodeMap?

    init(nodePositioning: NodePositioning) {
        self.nodePositioning = nodePositioning

        let sideLength = nodePositioning.sideLength
        let prototypes = NodePrototypes(sideLength: sideLength)

        cube1 = prototypes.createCube(colour: .red)
        cube2 = prototypes.createCube(colour: .yellow)
        wedge = prototypes.createWedge()
        sentinel = prototypes.createSentinel()
        guardian = prototypes.createGuardian()
        player = prototypes.createPlayer()
        tree = prototypes.createTree()

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

    func createTerrainNode(grid: Grid) -> SCNNode {
        let nodeMap = NodeMap()
        let terrainNode = SCNNode()
        terrainNode.name = terrainNodeName

        let width = grid.width
        let depth = grid.depth

        for z in 0 ..< depth {
            for x in 0 ..< width {
                if let gridPiece = grid.get(point: GridPoint(x: x, z: z)) {
                    if gridPiece.isFlat {
                        let node = createFlatPiece(x: x,
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

        self.nodeMap = nodeMap

        if let sentinelPiece = grid.get(point: grid.sentinelPosition) {
            let sentinelNode = createSentinelNode(piece: sentinelPiece)
            terrainNode.addChildNode(sentinelNode)
        }

        for guardianPosition in grid.guardianPositions {
            if let guardianPiece = grid.get(point: guardianPosition) {
                let guardianNode = createGuardianNode(piece: guardianPiece)
                terrainNode.addChildNode(guardianNode)
            }
        }

        if let startPiece = grid.get(point: grid.startPosition) {
            let playerNode = createPlayerNode(piece: startPiece)
            terrainNode.addChildNode(playerNode)
        }

        for treePosition in grid.treePositions {
            if let treePiece = grid.get(point: treePosition) {
                let treeNode = createTreeNode(piece: treePiece)
                terrainNode.addChildNode(treeNode)
            }
        }

        return terrainNode
    }

    func createSentinelNode(piece: GridPiece) -> SCNNode {
        let clone = sentinel.clone()
        let point = piece.point
        let level = Int(piece.level)
        clone.position = nodePositioning.calculatePosition(x: point.x, y: level, z: point.z)
        return clone
    }

    func createGuardianNode(piece: GridPiece) -> SCNNode {
        let clone = guardian.clone()
        let point = piece.point
        let level = Int(piece.level)
        clone.position = nodePositioning.calculatePosition(x: point.x, y: level, z: point.z)
        return clone
    }

    func createPlayerNode(piece: GridPiece) -> SCNNode {
        let clone = player.clone()
        let point = piece.point
        let level = Int(piece.level)
        clone.position = nodePositioning.calculatePosition(x: point.x, y: level, z: point.z)
        return clone
    }

    func createTreeNode(piece: GridPiece) -> SCNNode {
        let clone = tree.clone()
        let point = piece.point
        let level = Int(piece.level)
        clone.position = nodePositioning.calculatePosition(x: point.x, y: level, z: point.z, height: 2)
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
            if !gridPiece.isFlat {
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

    private func createFlatPiece(x: Int, y: Int, z: Int) -> SCNNode {
        let source = (x + z + Int(y)) % 2 == 0 ? cube1 : cube2
        let boxNode = source.clone()
        boxNode.position = nodePositioning.calculatePosition(x: x, y: y, z: z)
        return boxNode
    }

    private func createWedgePiece(x: Int, y: Int, z: Int, rotation: SCNVector4? = nil) -> SCNNode {
        let clone = wedge.clone()
        clone.position = nodePositioning.calculatePosition(x: x, y: y, z: z)
        if let rotation = rotation {
            clone.rotation = rotation
        }
        return clone
    }

    private func createWallPiece(x: Int, z: Int, height: Int) -> [SCNNode] {
        var wallNodes: [SCNNode] = []
        for y in 0 ..< height {
            let wallNode = createFlatPiece(x: x, y: y - 1, z: z)
            wallNodes.append(wallNode)
        }
        return wallNodes
    }
}

fileprivate class NodePrototypes: NSObject {
    let sideLength: Float

    let geometryFactory = GeometryFactory()

    init(sideLength: Float) {
        self.sideLength = sideLength

        super.init()
    }

    func createCube(colour: UIColor) -> SCNNode {
        let cube = geometryFactory.createCube(size: sideLength, colour: colour)
        let cubeNode = SCNNode(geometry: cube)
        cubeNode.name = flatNodeName
        return cubeNode
    }

    func createWedge() -> SCNNode {
        let wedge = geometryFactory.createWedge(size: sideLength, colour: .darkGray)
        let wedgeNode = SCNNode(geometry: wedge)
        wedgeNode.name = slopeNodeName
        return wedgeNode
    }

    func createSentinel() -> SCNNode {
        let sentinelNode = createSphere(colour: .blue)
        sentinelNode.name = sentinelNodeName
        return sentinelNode
    }

    func createGuardian() -> SCNNode {
        let guardianNode = createSphere(colour: .green)
        guardianNode.name = guardianNodeName
        return guardianNode
    }

    func createSphere(colour: UIColor) -> SCNNode {
        let material = SCNMaterial()
        material.diffuse.contents = colour
        let sphere = SCNSphere(radius: CGFloat(sideLength / 3.0))
        sphere.firstMaterial = material
        return SCNNode(geometry: sphere)
    }

    func createPlayer() -> SCNNode {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.purple
        let capsule = SCNCapsule(capRadius: CGFloat(sideLength / 3.0), height: CGFloat(sideLength))
        capsule.firstMaterial = material
        let playerNode = SCNNode(geometry: capsule)
        playerNode.name = playerNodeName
        return playerNode
    }

    func createTree() -> SCNNode {
        let width = CGFloat(sideLength)
        let height = width * 2.0
        let maxRadius = width / 2.0

        let trunkHeight: CGFloat = height * 3.0 / 10.0
        let trunkRadius: CGFloat = maxRadius * 0.2

        let treeNode = SCNNode()
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

        treeNode.name = treeNodeName
        return treeNode
    }
}
