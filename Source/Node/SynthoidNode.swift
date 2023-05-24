import SceneKit

let synthoidNodeName = "synthoidNodeName"

private let elevationLock = Float.pi / 6.0

class SynthoidNode: SCNNode, PlaceableNode, ViewingNode, DetectableNode {
    private var rotationRadians: Float = 0.0
    private var elevationRadians: Float = 0.0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init() {
        super.init()

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.purple
        let radius = Float.floorSize / 3.0
        let capsule = SCNCapsule(capRadius: CGFloat(radius), height: .floorSize)
        capsule.firstMaterial = material

        let capsuleNode = SCNNode(geometry: capsule)
        addChildNode(capsuleNode)

        let eyeNode = EyeNode()
        eyeNode.position.y += .floorSize / 4.0
        eyeNode.position.z = -radius
        addChildNode(eyeNode)

        name = synthoidNodeName
        categoryBitMask |= interactiveNodeBitMask
        pivot = SCNMatrix4MakeTranslation(0.0, -0.5 * .floorSize, 0.0)
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
