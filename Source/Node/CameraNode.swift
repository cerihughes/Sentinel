import SceneKit

let cameraNodeName = "cameraNodeName"

class CameraNode: SCNNode {
    override private init() {
        super.init()
    }

    init(zFar: Double?) {
        super.init()
        let camera = SCNCamera()
        if let zFar = zFar {
            camera.zFar = zFar
        } else {
            camera.automaticallyAdjustsZRange = true
        }
        name = cameraNodeName
        self.camera = camera
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
