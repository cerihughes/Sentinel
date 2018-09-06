import GLKit
import SceneKit

let cameraNodeName = "cameraNodeName"
let terrainNodeName = "terrainNodeName"
let flatNodeName = "flatNodeName"
let slopeNodeName = "slopeNodeName"
let sentinelNodeName = "sentinelNodeName"
let guardianNodeName = "guardianNodeName"
let playerNodeName = "playerNodeName"

class NodeFactory: NSObject {
    let sideLength: Float
    let nodePositioning: NodePositioning

    let geometryFactory = GeometryFactory()
    let cube1: SCNNode
    let cube2: SCNNode
    let wedge: SCNNode

    let sentinel: SCNNode
    let guardian: SCNNode
    let player: SCNNode

    var nodeMap: NodeMap?

    init(nodePositioning: NodePositioning) {
        self.sideLength = nodePositioning.sideLength
        self.nodePositioning = nodePositioning

        let redCube = geometryFactory.createCube(size: sideLength, colour: .red)
        cube1 = SCNNode(geometry: redCube)
        cube1.name = flatNodeName

        let yellowCube = geometryFactory.createCube(size: sideLength, colour: .yellow)
        cube2 = SCNNode(geometry: yellowCube)
        cube2.name = flatNodeName

        let greyWedge = geometryFactory.createWedge(size: sideLength, colour: .darkGray)
        wedge = SCNNode(geometry: greyWedge)
        wedge.name = slopeNodeName

        // Sentinel
        var material = SCNMaterial()
        material.diffuse.contents = UIColor.blue

        var sphere = SCNSphere(radius: CGFloat(sideLength / 3.0))
        sphere.firstMaterial = material

        sentinel = SCNNode(geometry: sphere)
        sentinel.name = sentinelNodeName

        // Guardian
        material = material.copy() as! SCNMaterial
        material.diffuse.contents = UIColor.green

        sphere = sphere.copy() as! SCNSphere
        sphere.firstMaterial = material

        guardian = SCNNode(geometry: sphere)
        guardian.name = guardianNodeName

        // Player
        material = material.copy() as! SCNMaterial
        material.diffuse.contents = UIColor.purple

        let capsule = SCNCapsule(capRadius: CGFloat(sideLength / 3.0), height: CGFloat(sideLength))
        capsule.firstMaterial = material

        player = SCNNode(geometry: capsule)
        player.name = playerNodeName

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
                                                   y: gridPiece.level - 1.0,
                                                   z: z)
                        terrainNode.addChildNode(node)
                        nodeMap.add(node: node, for: gridPiece)
                    } else {
                        for direction in GridDirection.allValues() {
                            if gridPiece.has(slopeDirection: direction) {
                                let node = createWedgePiece(x: x,
                                                            y: gridPiece.level - 0.5,
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

        return terrainNode
    }

    func createSentinelNode(piece: GridPiece) -> SCNNode {
        let clone = sentinel.clone()
        let point = piece.point
        let level = piece.level
        clone.position = nodePositioning.calculatePosition(x: point.x, y: level, z: point.z)
        return clone
    }

    func createGuardianNode(piece: GridPiece) -> SCNNode {
        let clone = guardian.clone()
        let point = piece.point
        let level = piece.level
        clone.position = nodePositioning.calculatePosition(x: point.x, y: level, z: point.z)
        return clone
    }

    func createPlayerNode(piece: GridPiece) -> SCNNode {
        let clone = player.clone()
        let point = piece.point
        let level = piece.level
        clone.position = nodePositioning.calculatePosition(x: point.x, y: level, z: point.z)
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

    private func createFlatPiece(x: Int, y: Float, z: Int) -> SCNNode {
        let source = (x + z + Int(y)) % 2 == 0 ? cube1 : cube2
        let boxNode = source.clone()
        boxNode.position = nodePositioning.calculatePosition(x: x, y: y, z: z)
        return boxNode
    }

    private func createWedgePiece(x: Int, y: Float, z: Int, rotation: SCNVector4? = nil) -> SCNNode {
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
            let wallNode = createFlatPiece(x: x, y: Float(y - 1), z: z)
            wallNodes.append(wallNode)
        }
        return wallNodes
    }
}
