import GLKit
import SceneKit

class NodeFactory: NSObject {
    let sideLength: Float
    let thickness: Float

    let geometryFactory = GeometryFactory()
    let flatNode1: SCNNode
    let flatNode2: SCNNode
    let wedgeNode: SCNNode

    init(sideLength: Float, thickness: Float) {
        self.sideLength = sideLength
        self.thickness = thickness

        // Red box
        var material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.locksAmbientWithDiffuse = true

        var flatBox = SCNBox(width: CGFloat(sideLength),
                             height: CGFloat(thickness),
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
        material.diffuse.contents = UIColor.darkGray

        let wedge = geometryFactory.createWedge(size: sideLength)
        wedge.firstMaterial = material
        self.wedgeNode = SCNNode(geometry: wedge)

        super.init()
    }

    public func createTerrainNode(grid: Grid) -> SCNNode {
        let terrainNode = SCNNode()

        let width = grid.width
        let depth = grid.depth

        for z in 0 ..< depth {
            for x in 0 ..< width {
                let gridPiece = grid.get(point: GridPoint(x: x, z: z))
                for gridShape in gridPiece.shapes {
                    switch gridShape {
                    case .flat:
                        let node = createFlatPiece(grid: grid,
                                                   x: x,
                                                   y: Float(gridPiece.level),
                                                   z: z)
                        terrainNode.addChildNode(node)
                    case .slopeUpX:
                        let node = createWedgePiece(grid: grid,
                                                    x: x,
                                                    y: Float(gridPiece.level) + 0.5,
                                                    z: z,
                                                    rotation: SCNVector4Make(0.0, 1.0, 0.0, Float.pi))
                        terrainNode.addChildNode(node)
                    case .slopeDownX:
                        let node = createWedgePiece(grid: grid,
                                                    x: x,
                                                    y: Float(gridPiece.level) + 0.5,
                                                    z: z)
                        terrainNode.addChildNode(node)
                    case .slopeUpZ:
                        let node = createWedgePiece(grid: grid,
                                                    x: x,
                                                    y: Float(gridPiece.level) + 0.5,
                                                    z: z,
                                                    rotation: SCNVector4Make(0.0, 1.0, 0.0, Float.pi / 2.0))
                        terrainNode.addChildNode(node)
                    case .slopeDownZ:
                        let node = createWedgePiece(grid: grid,
                                                    x: x,
                                                    y: Float(gridPiece.level) + 0.5,
                                                    z: z,
                                                    rotation: SCNVector4Make(0.0, 1.0, 0.0, Float.pi / -2.0))
                        terrainNode.addChildNode(node)
                    }
                }
            }
        }
        return terrainNode
    }
}

extension NodeFactory {
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
}
