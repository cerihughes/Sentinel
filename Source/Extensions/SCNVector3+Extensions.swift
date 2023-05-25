import SceneKit

extension SCNVector3 {
    static func randomValues(range: Float) -> SCNVector3 {
        .init(
            .random(in: -range ..< range),
            .random(in: -range ..< range),
            .random(in: -range ..< range)
        )
    }

    func opposite() -> SCNVector3 {
        .init(-x, -y, -z)
    }

    func addingRandomValues(in range: Float) -> SCNVector3 {
        adding(vector: .randomValues(range: range))
    }

    func adding(vector: SCNVector3) -> SCNVector3 {
        .init(vector.x + x, vector.y + y, vector.z + z)
    }

    func adding(x: Float = 0, y: Float = 0, z: Float = 0) -> SCNVector3 {
        adding(vector: .init(x, y, z))
    }
}
