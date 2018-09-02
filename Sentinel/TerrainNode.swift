import GLKit
import SceneKit

class TerrainNode: SCNNode {
    let grid: Grid
    let sideLength: Float
    let thickness: Float

    let squareNode1: SCNNode
    let squareNode2: SCNNode
    let slopeNode: SlopeNode

    init(grid: Grid,
         sideLength: Float,
         thickness: Float) {
        self.grid = grid
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

        self.squareNode1 = SCNNode(geometry: flatBox)

        // Yellow box
        material = material.copy() as! SCNMaterial
        material.diffuse.contents = UIColor.yellow

        flatBox = flatBox.copy() as! SCNBox
        flatBox.firstMaterial = material

        self.squareNode2 = SCNNode(geometry: flatBox)

        // Grey slope
        self.slopeNode = SlopeNode()
        self.slopeNode.createChildren(sideLength: sideLength, thickness: thickness)

        super.init()

        generateTerrain()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func generateTerrain() {
        let width = grid.width
        let depth = grid.depth

        for z in 0 ..< depth {
            for x in 0 ..< width {
                let gridPiece = grid.get(point: GridPoint(x: x, z: z))
                for gridShape in gridPiece.shapes {
                    switch gridShape {
                    case .flat:
                        let node = createFlatPiece(x: x,
                                                   y: Float(gridPiece.level),
                                                   z: z)
                        addChildNode(node)
                    case .slopeUpX:
                        let node = createSlopePiece(x: x,
                                                    y: Float(gridPiece.level) + 0.5,
                                                    z: z,
                                                    rotation: SCNVector4Make(0.0, 1.0, 0.0, Float.pi))
                        addChildNode(node)
                    case .slopeDownX:
                        let node = createSlopePiece(x: x,
                                                    y: Float(gridPiece.level) + 0.5,
                                                    z: z)
                        addChildNode(node)
                    case .slopeUpZ:
                        let node = createSlopePiece(x: x,
                                                    y: Float(gridPiece.level) + 0.5,
                                                    z: z,
                                                    rotation: SCNVector4Make(0.0, 1.0, 0.0, Float.pi / 2.0))
                        addChildNode(node)
                    case .slopeDownZ:
                        let node = createSlopePiece(x: x,
                                                    y: Float(gridPiece.level) + 0.5,
                                                    z: z,
                                                    rotation: SCNVector4Make(0.0, 1.0, 0.0, Float.pi / -2.0))
                        addChildNode(node)
                    }
                }
            }
        }
    }

    private func createFlatPiece(x: Int, y: Float, z: Int) -> SCNNode {
        let source = (x + z) % 2 == 0 ? squareNode1 : squareNode2
        let boxNode = source.clone()
        boxNode.position = calculatePosition(x: x, y: y, z: z)
        return boxNode
    }

    private func createSlopePiece(x: Int, y: Float, z: Int, rotation: SCNVector4? = nil) -> SCNNode {
        let clone = slopeNode.clone()
        clone.position = calculatePosition(x: x, y: y, z: z)
        if let rotation = rotation {
            clone.rotation = rotation
        }
        return clone
    }

    private func calculatePosition(x: Int, y: Float, z: Int) -> SCNVector3 {
        let width = Float(grid.width)
        let depth = Float(grid.depth)
        return SCNVector3Make((Float(x) - (width / 2.0)) * Float(sideLength),
                              y * Float(sideLength),
                              (Float(z) - (depth / 2.0)) * Float(sideLength))
    }
}
