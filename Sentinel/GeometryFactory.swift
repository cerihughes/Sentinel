import SceneKit

class GeometryFactory: NSObject {

    func createWedge(size: Float) -> SCNGeometry {
        let halfSide = size / 2.0

        let vertices: [SCNVector3] = [
            // Front
            SCNVector3Make(-halfSide,  halfSide,  halfSide), //  0
            SCNVector3Make(-halfSide, -halfSide,  halfSide), //  1
            SCNVector3Make( halfSide, -halfSide,  halfSide), //  2

            // Back
            SCNVector3Make(-halfSide,  halfSide, -halfSide), //  3
            SCNVector3Make(-halfSide, -halfSide, -halfSide), //  4
            SCNVector3Make( halfSide, -halfSide, -halfSide), //  5

            // Diagonal
            SCNVector3Make(-halfSide,  halfSide,  halfSide), // 6 = 0'
            SCNVector3Make(-halfSide,  halfSide, -halfSide), // 7 = 3'
            SCNVector3Make( halfSide, -halfSide,  halfSide), // 8 = 2'
            SCNVector3Make( halfSide, -halfSide, -halfSide), // 9 = 5'
        ]

        let triangleIndices: [UInt8] = [
            // Front
            0, 1, 2,

            // Back
            3, 5, 4,

            // Diagonal
            6, 8, 7, // 0, 2, 3,
            7, 8, 9, // 3, 2, 5,
        ]

        let normals: [SCNVector3] = [
            // Front
            SCNVector3Make(0, 0, -1),
            SCNVector3Make(0, 0, -1),
            SCNVector3Make(0, 0, -1),

            // Back
            SCNVector3Make(0, 0, 1),
            SCNVector3Make(0, 0, 1),
            SCNVector3Make(0, 0, 1),

            // Diagonal ???
            SCNVector3Make(-1, -0.5, 0),
            SCNVector3Make(-1, -0.5, 0),
            SCNVector3Make(-1, -0.5, 0),
            SCNVector3Make(-1, -0.5, 0),
            ]

        let vertexSource = SCNGeometrySource(vertices: vertices)
        let normalSource = SCNGeometrySource(normals: normals)

        let triangleElement = SCNGeometryElement(indices: triangleIndices, primitiveType: .triangles)

        return SCNGeometry(sources: [vertexSource, normalSource],
                           elements: [triangleElement])
    }
}
