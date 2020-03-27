import SceneKit

let eyeNodeName = "eyeNodeName"

class EyeNode: SCNNode {
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(floorSize: Float, detectionRadius: Float? = nil, options: [NodeFactoryOption]) {
        super.init()

        let width = CGFloat(floorSize / 3.0)
        let height = CGFloat(floorSize / 10.0)

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        let box = SCNBox(width: width, height: height, length: height, chamferRadius: 0.2)
        box.materials = [material]
        let boxNode = SCNNode(geometry: box)

        let camera = SCNCamera()
        camera.projectionDirection = .horizontal
        camera.fieldOfView = 60.0

        let cameraNode = SCNNode()
        cameraNode.name = cameraNodeName
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(0.0, 0.0, floorSize / -10.0)

        let useVisionNode = options.contains(.showVisionNode(true)) || options.contains(.showVisionNode(false))

        if let detectionRadius = detectionRadius {
            camera.zFar = Double(detectionRadius)
            if useVisionNode {
                let visionNode = VisionNode(camera: camera, aspectRatio: 1024.0 / 768.0)
                visionNode.position = SCNVector3Make(0, 0, Float(-camera.zFar))
                cameraNode.addChildNode(visionNode)
            }
        } else {
            camera.automaticallyAdjustsZRange = true
        }

        boxNode.addChildNode(cameraNode)
        addChildNode(boxNode)

        name = eyeNodeName
    }

    var cameraNode: SCNNode {
        return childNode(withName: cameraNodeName, recursively: true)!
    }
}
