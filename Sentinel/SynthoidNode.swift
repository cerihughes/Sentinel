import SceneKit

fileprivate let elevationLock = Float.pi / 6.0

class SynthoidNode: SCNNode, PlaceableNode, ViewingNode, DetectableNode {
    private var rotationRadians: Float = 0.0
    private var elevationRadians: Float = 0.0

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

    func apply(rotationDelta: Float, elevationDelta: Float, persist: Bool) {
        let newRotationAngle = rotationRadians + rotationDelta
        var newElevationAngle = elevationRadians + elevationDelta

        if newElevationAngle > elevationLock {
            newElevationAngle = elevationLock
        } else if newElevationAngle < -elevationLock {
            newElevationAngle = -elevationLock
        }

        let oldPosition = position
        transform = SCNMatrix4MakeRotation(newRotationAngle, 0, 1, 0)
        cameraNode.transform = SCNMatrix4MakeRotation(newElevationAngle, 1, 0, 0)
        position = oldPosition

        if persist {
            rotationRadians = newRotationAngle
            elevationRadians = newElevationAngle
        }
    }
}
