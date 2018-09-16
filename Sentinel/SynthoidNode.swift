import SceneKit

class SynthoidNode: SCNNode, InteractiveNode {
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(floorSize: Float) {
        super.init()
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.purple
        let capsule = SCNCapsule(capRadius: CGFloat(floorSize / 3.0), height: CGFloat(floorSize))
        capsule.firstMaterial = material

        geometry = capsule
        name = synthoidNodeName
        categoryBitMask = interactiveNodeType.synthoid.rawValue
        pivot = SCNMatrix4MakeTranslation(0.0, -0.5 * floorSize, 0.0)
    }

    var floorNode: FloorNode? {
        return parent as? FloorNode
    }
}
