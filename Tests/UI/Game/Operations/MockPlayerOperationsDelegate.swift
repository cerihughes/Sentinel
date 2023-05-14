import SceneKit
@testable import Sentinel

class MockPlayerOperationsDelegate: PlayerOperationsDelegate {
    var lastCameraNode: SCNNode?
    func playerOperations(_ playerOperations: PlayerOperations, didChange cameraNode: SCNNode) {
        lastCameraNode = cameraNode
    }

    var lastOperation: PlayerOperations.Operation?
    func playerOperations(_ playerOperations: PlayerOperations, didPerform operation: PlayerOperations.Operation) {
        lastOperation = operation
    }
}
