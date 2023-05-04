import SceneKit
@testable import Sentinel

class MockGameViewModelDelegate: GameViewModelDelegate {
    var cameraNode: SCNNode?
    var endState: GameViewModel.EndState?

    func gameViewModel(_ gameViewModel: GameViewModel, changeCameraNodeTo node: SCNNode) {
        cameraNode = node
    }

    func gameViewModel(_ gameViewModel: GameViewModel, levelDidEndWith state: GameViewModel.EndState) {
        endState = state
    }
}
