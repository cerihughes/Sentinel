import SceneKit

let eyeNodeName = "eyeNodeName"

class EyeNode: SCNNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init() {
        super.init()

        let width = CGFloat.floorSize / 3.0
        let height = CGFloat.floorSize / 10.0

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        let box = SCNBox(width: width, height: height, length: height, chamferRadius: 0.2)
        box.materials = [material]
        let boxNode = SCNNode(geometry: box)

        let camera = SCNCamera()
        camera.projectionDirection = .horizontal
        camera.zNear = 1
        camera.zFar = 10000 // automaticallyAdjustsZRange doesn't seem to work...
        camera.wantsDepthOfField = true
        camera.wantsHDR = true
        camera.motionBlurIntensity = 0.25

        let cameraNode = SCNNode()
        cameraNode.name = cameraNodeName
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(0.0, 0.0, .floorSize / -10.0)

        boxNode.addChildNode(cameraNode)
        addChildNode(boxNode)

        name = eyeNodeName
    }

    var cameraNode: SCNNode {
        childNode(withName: cameraNodeName, recursively: true)!
    }
}
