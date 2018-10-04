import SceneKit

class VisionNode: SCNNode {
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience init(camera: SCNCamera, aspectRatio: CGFloat) {
        self.init(hFOV: camera.fieldOfView, aspectRatio: aspectRatio, zFar: CGFloat(camera.zFar))
    }

    init(hFOV hDegrees: CGFloat, aspectRatio: CGFloat, zFar: CGFloat) {
        super.init()

        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
        let pyramid = SCNPyramid(hFOV: hDegrees, aspectRatio: aspectRatio, zFar: zFar)
        pyramid.materials = [material]
        let node = SCNNode(geometry: pyramid)
        node.rotation = SCNVector4Make(1.0, 0.0, 0.0, Float.pi / 2.0)
        node.categoryBitMask |= noninteractiveNodeBitMask
        addChildNode(node)
    }
}
