import SceneKit
@testable import Sentinel

class MockOpponentsOperationsDelegate: OpponentsOperationsDelegate {
    var opponentsOperationsDidAbsorbCalls = 0
    func opponentsOperationsDidAbsorb(_ opponentsOperations: OpponentsOperations) {
        opponentsOperationsDidAbsorbCalls += 1
    }

    var opponentsOperationsDidDepleteEnergyResult = true
    var opponentsOperationsDidDepleteEnergyCalls = 0
    func opponentsOperationsDidDepleteEnergy(_ opponentsOperations: OpponentsOperations) -> Bool {
        opponentsOperationsDidDepleteEnergyCalls += 1
        return opponentsOperationsDidDepleteEnergyResult
    }

    var lastDetectOpponent: SCNNode?
    func opponentsOperations(_ opponentsOperations: OpponentsOperations, didDetectOpponent cameraNode: SCNNode) {
        lastDetectOpponent = cameraNode
    }

    var lastEndDetectOpponent: SCNNode?
    func opponentsOperations(_ opponentsOperations: OpponentsOperations, didEndDetectOpponent cameraNode: SCNNode) {
        lastEndDetectOpponent = cameraNode
    }
}
