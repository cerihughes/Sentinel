import SceneKit

class TerrainNode: SCNNode {
    let grid: Grid
    let sideLength: Float
    let thickness: Float
    let hypotenuse: Float

    init(grid: Grid,
         sideLength: Float,
         thickness: Float = 0.1) {
        self.grid = grid
        self.sideLength = sideLength
        self.thickness = thickness

        self.hypotenuse = sqrtf(Float(powf(sideLength, 2.0)) * 2.0)

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
                        let colour = (x + z) % 2 == 0 ? UIColor.red : UIColor.yellow
                        let node = createFlatPiece(x: Float(x),
                                                   y: Float(gridPiece.level),
                                                   z: Float(z),
                                                   colour: colour)
                        addChildNode(node)
                    case .slopeUpX:
                        let node = createSlopeXPiece(x: Float(x),
                                                     y: Float(gridPiece.level) - 0.5,
                                                     z: Float(z),
                                                     rotation: SCNVector4Make(0.0, 0.0, 1.0, Float.pi / 4.0))
                        addChildNode(node)
                    case .slopeDownX:
                        let node = createSlopeXPiece(x: Float(x),
                                                     y: Float(gridPiece.level) - 0.5,
                                                     z: Float(z),
                                                     rotation: SCNVector4Make(0.0, 0.0, 1.0, Float.pi / -4.0))
                        addChildNode(node)
                    case .slopeUpZ:
                        let node = createSlopeZPiece(x: Float(x),
                                                     y: Float(gridPiece.level) - 0.5,
                                                     z: Float(z),
                                                     rotation: SCNVector4Make(1.0, 0.0, 0.0, Float.pi / -4.0))
                        addChildNode(node)
                    case .slopeDownZ:
                        let node = createSlopeZPiece(x: Float(x),
                                                     y: Float(gridPiece.level) - 0.5,
                                                     z: Float(z),
                                                     rotation: SCNVector4Make(1.0, 0.0, 0.0, Float.pi / 4.0))
                        addChildNode(node)
                    }
                }
            }
        }
    }

    private func createFlatPiece(x: Float, y: Float, z: Float, colour: UIColor) -> SCNNode {
        let material = SCNMaterial()
        material.diffuse.contents = colour
        material.locksAmbientWithDiffuse = true

        let box = SCNBox(width: CGFloat(sideLength),
                         height: CGFloat(thickness),
                         length: CGFloat(sideLength),
                         chamferRadius: 0.0)
        box.firstMaterial = material

        let boxNode = SCNNode(geometry: box)
        boxNode.position = calculatePosition(x: x, y: y, z: z)
        return boxNode
    }

    private func createSlopeXPiece(x: Float, y: Float, z: Float, rotation: SCNVector4) -> SCNNode {
        return createSlopePiece(x: x,
                                y: y,
                                z: z,
                                w: hypotenuse,
                                l: sideLength,
                                rotation: rotation)
    }

    private func createSlopeZPiece(x: Float, y: Float, z: Float, rotation: SCNVector4) -> SCNNode {
        return createSlopePiece(x: x,
                                y: y,
                                z: z,
                                w: sideLength,
                                l: hypotenuse,
                                rotation: rotation)
    }

    private func createSlopePiece(x: Float, y: Float, z: Float, w: Float, l: Float, rotation: SCNVector4) -> SCNNode {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.darkGray
        material.locksAmbientWithDiffuse = true

        let box = SCNBox(width: CGFloat(w),
                         height: CGFloat(thickness),
                         length: CGFloat(l),
                         chamferRadius: 0.0)
        box.firstMaterial = material

        let boxNode = SCNNode(geometry: box)
        boxNode.position = calculatePosition(x: x, y: y, z: z)
        boxNode.rotation = rotation
        return boxNode
    }

    private func calculatePosition(x: Float, y: Float, z: Float) -> SCNVector3 {
        let width = Float(grid.width)
        let depth = Float(grid.depth)
        return SCNVector3Make((x - (width / 2.0)) * Float(sideLength),
                              y * Float(sideLength),
                              (z - (depth / 2.0)) * Float(sideLength))
    }
}
