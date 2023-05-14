import SceneKit
@testable import Sentinel

class MockGameViewModelDelegate: GameViewModelDelegate {
    var lastCameraNode: SCNNode?
    func gameViewModel(_ gameViewModel: GameViewModel, changeCameraNodeTo node: SCNNode) {
        lastCameraNode = node
    }

    var lastOutcome: LevelScore.Outcome?
    func gameViewModel(_ gameViewModel: GameViewModel, levelDidEndWith outcome: LevelScore.Outcome) {
        lastOutcome = outcome
    }
}
