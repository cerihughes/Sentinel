import SceneKit

let detectionAreaNodeName = "detectionAreaNodeName"

class DetectionAreaNode: SCNNode {
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(detectionRadius: Float) {
        super.init()

        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 1.0, green: 0.8, blue: 0.8, alpha: 0.2)

        let sphere = SCNSphere(radius: CGFloat(detectionRadius))
        sphere.firstMaterial = material

        geometry = sphere
        
        name = detectionAreaNodeName
        categoryBitMask |= noninteractiveNodeBitMask
    }
}
