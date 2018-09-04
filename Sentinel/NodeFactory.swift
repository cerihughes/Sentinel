import GLKit
import SceneKit

fileprivate let slopeColour = UIColor.darkGray

class NodeFactory: NSObject {
    let sideLength: Float

    let geometryFactory = GeometryFactory()
    let flatNode1: SCNNode
    let flatNode2: SCNNode
    let wedgeNode: SCNNode
    var wallNodeCache: [Int:SCNNode] = [:]

    let sentinelNode: SCNNode
    let guardianNode: SCNNode

    init(sideLength: Float) {
        self.sideLength = sideLength

        // Red box
        var material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.locksAmbientWithDiffuse = true

        var flatBox = SCNBox(width: CGFloat(sideLength),
                             height: CGFloat(sideLength),
                             length: CGFloat(sideLength),
                             chamferRadius: 0.0)
        flatBox.firstMaterial = material

        self.flatNode1 = SCNNode(geometry: flatBox)

        // Yellow box
        material = material.copy() as! SCNMaterial
        material.diffuse.contents = UIColor.yellow

        flatBox = flatBox.copy() as! SCNBox
        flatBox.firstMaterial = material

        self.flatNode2 = SCNNode(geometry: flatBox)

        // Grey wedge
        material = material.copy() as! SCNMaterial
        material.diffuse.contents = slopeColour

        let wedge = geometryFactory.createWedge(size: sideLength)
        wedge.firstMaterial = material
        self.wedgeNode = SCNNode(geometry: wedge)

        // Sentinel
        material = material.copy() as! SCNMaterial
        material.diffuse.contents = UIColor.blue

        var sphere = SCNSphere(radius: CGFloat(sideLength / 3.0))
        sphere.firstMaterial = material

        self.sentinelNode = SCNNode(geometry: sphere)

        // Guardian
        material = material.copy() as! SCNMaterial
        material.diffuse.contents = UIColor.green

        sphere = sphere.copy() as! SCNSphere
        sphere.firstMaterial = material

        self.guardianNode = SCNNode(geometry: sphere)

        super.init()
    }

    func createTerrainNode(grid: Grid) -> SCNNode {
        let terrainNode = SCNNode()

        let width = grid.width
        let depth = grid.depth

        for z in 0 ..< depth {
            for x in 0 ..< width {
                if let gridPiece = grid.get(point: GridPoint(x: x, z: z)) {
                    if gridPiece.isFlat {
                        let node = createFlatPiece(grid: grid,
                                                   x: x,
                                                   y: gridPiece.level - 1.0,
                                                   z: z)
                        terrainNode.addChildNode(node)
                    } else {
                        for direction in GridDirection.allValues() {
                            if gridPiece.has(slopeDirection: direction) {
                                let node = createWedgePiece(grid: grid,
                                                            x: x,
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

        return terrainNode
    }

    func createSentinelNode(grid: Grid, piece: GridPiece) -> SCNNode {
        let clone = sentinelNode.clone()
        let point = piece.point
        let level = piece.level
        clone.position = calculatePosition(grid: grid, x: point.x, y: level, z: point.z)
        return clone
    }

    func createGuardianNode(grid: Grid, piece: GridPiece) -> SCNNode {
        let clone = guardianNode.clone()
        let point = piece.point
        let level = piece.level
        clone.position = calculatePosition(grid: grid, x: point.x, y: level, z: point.z)
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
            let node = createWallPiece(grid: grid, x: x, z: z, height: Int(height))
            terrainNode.addChildNode(node)
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

    private func createFlatPiece(grid: Grid, x: Int, y: Float, z: Int) -> SCNNode {
        let source = (x + z) % 2 == 0 ? flatNode1 : flatNode2
        let boxNode = source.clone()
        boxNode.position = calculatePosition(grid: grid, x: x, y: y, z: z)
        return boxNode
    }

    private func createWedgePiece(grid: Grid, x: Int, y: Float, z: Int, rotation: SCNVector4? = nil) -> SCNNode {
        let clone = wedgeNode.clone()
        clone.position = calculatePosition(grid: grid, x: x, y: y, z: z)
        if let rotation = rotation {
            clone.rotation = rotation
        }
        return clone
    }

    private func calculatePosition(grid: Grid, x: Int, y: Float, z: Int) -> SCNVector3 {
        let width = Float(grid.width)
        let depth = Float(grid.depth)
        return SCNVector3Make((Float(x) - (width / 2.0)) * Float(sideLength),
                              y * Float(sideLength),
                              (Float(z) - (depth / 2.0)) * Float(sideLength))
    }


    private func createWallPiece(grid: Grid, x: Int, z: Int, height: Int) -> SCNNode {
        let wallNode = getOrCreateWallNode(height: height)
        wallNode.position = calculateWallPosition(grid: grid, x: x, z: z, height: height)
        return wallNode
    }

    private func getOrCreateWallNode(height: Int) -> SCNNode {
        if let existingNode = wallNodeCache[height] {
            return existingNode.clone()
        }

        let material = SCNMaterial()
        material.diffuse.contents = slopeColour
        material.locksAmbientWithDiffuse = true

        let wall = SCNBox(width: CGFloat(sideLength),
                          height: CGFloat(height) * CGFloat(sideLength),
                          length: CGFloat(sideLength),
                          chamferRadius: 0.0)
        wall.firstMaterial = material

        let wallNode = SCNNode(geometry: wall)
        wallNodeCache[height] = wallNode
        return wallNode
    }

    private func calculateWallPosition(grid: Grid, x: Int, z: Int, height: Int) -> SCNVector3 {
        let width = Float(grid.width)
        let depth = Float(grid.depth)
        let centerPoint = Float(height - 3) / 2.0
        return SCNVector3Make((Float(x) - (width / 2.0)) * Float(sideLength),
                              centerPoint * Float(sideLength),
                              (Float(z) - (depth / 2.0)) * Float(sideLength))
    }
}
