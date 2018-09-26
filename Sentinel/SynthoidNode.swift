import SceneKit

class SynthoidNode: SCNNode, PlaceableNode, ViewingNode, DetectableNode {
    var viewingAngle: Float = 0.0 {
        didSet {
            let oldPosition = position
            transform = SCNMatrix4MakeRotation(viewingAngle, 0, 1, 0)
            position = oldPosition
        }
    }

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

        let capsuleNode = SCNNode(geometry: capsule)
        addChildNode(capsuleNode)
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true
        let cameraNode = SCNNode()
        cameraNode.position.y += floorSize / 4.0
        cameraNode.name = cameraNodeName
        cameraNode.camera = camera
        addChildNode(cameraNode)

        name = synthoidNodeName
        categoryBitMask = InteractiveNodeType.synthoid.rawValue
        pivot = SCNMatrix4MakeTranslation(0.0, -0.5 * floorSize, 0.0)
    }

    var floorNode: FloorNode? {
        return parent as? FloorNode
    }

    var cameraNode: SCNNode {
        return childNode(withName: cameraNodeName, recursively: true)!
    }

    var detectionNodes: [SCNNode] {
        return [self]
    }

    func apply(rotationDelta radians: Float, persist: Bool) {
        let newRadians = viewingAngle + radians
        let oldPosition = position
        transform = SCNMatrix4MakeRotation(newRadians, 0, 1, 0)
        position = oldPosition

        if persist {
            viewingAngle = newRadians
        }
    }
}
