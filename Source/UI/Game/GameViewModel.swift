import Combine
import SceneKit

protocol GameViewModelDelegate: AnyObject {
    func gameViewModel(_ gameViewModel: GameViewModel, changeCameraNodeTo node: SCNNode)
    func gameViewModel(_ gameViewModel: GameViewModel, levelDidEndWith state: GameViewModel.EndState)
}

class GameViewModel {
    enum EndState {
        case victory, defeat
    }

    let worldBuilder: WorldBuilder
    let built: WorldBuilder.Built
    let gameScore: GameScore
    weak var delegate: GameViewModelDelegate?
    var levelScore = LevelScore()

    private var cancellables: Set<AnyCancellable> = []

    init(worldBuilder: WorldBuilder, gameScore: GameScore) {
        self.worldBuilder = worldBuilder
        self.gameScore = gameScore
        built = worldBuilder.build()

        built.synthoidEnergy.energyPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: energyUpdated(_:))
            .store(in: &cancellables)

        built.playerOperations.delegate = self
    }

    private func energyUpdated(_ energy: Int) {
        guard energy <= 0 else { return }
        delegate?.gameViewModel(self, levelDidEndWith: .defeat)
    }
}

extension GameViewModel: PlayerOperationsDelegate {
    // MARK: PlayerOperationsDelegate

    func playerOperations(_ playerOperations: PlayerOperations, didChange cameraNode: SCNNode) {
        delegate?.gameViewModel(self, changeCameraNodeTo: cameraNode)
    }

    func playerOperations(_ playerOperations: PlayerOperations, didPerform operation: PlayerOperation) {
        switch operation {
        case .enterScene(let gridPoint):
            playerOperationsDidEnterScene(at: gridPoint)
        case .build(let buildableItem):
            playerOperationsDidBuild(buildableItem)
        case .absorb(let absorbableItem):
            playerOperationsDidAbsorb(absorbableItem)
        case .teleport(let gridPoint):
            playerOperationsDidTeleport(to: gridPoint)
        }
    }

    private func playerOperationsDidEnterScene(at gridPoint: GridPoint) {
        guard let gridPiece = built.grid.get(point: gridPoint), gridPiece.isFloor else { return }
        let floorHeight = Int(gridPiece.level)
        levelScore.didEnterScene(at: gridPoint, height: floorHeight)
    }

    private func playerOperationsDidBuild(_ buildableItem: BuildableItem) {
        levelScore.didBuildItem(buildableItem)
    }

    private func playerOperationsDidAbsorb(_ absorbableItem: AbsorbableItem) {
        levelScore.didAbsorbItem(absorbableItem)
        if absorbableItem == .sentinel {
            delegate?.gameViewModel(self, levelDidEndWith: .victory)
        }
    }

    private func playerOperationsDidTeleport(to gridPoint: GridPoint) {
        guard
            let floorNode = built.nodeManipulator.floorNode(for: gridPoint),
            let gridPiece = built.grid.get(point: gridPoint),
            gridPiece.isFloor
        else {
            return
        }

        let floorHeight = Int(gridPiece.level)
        let rockCount = floorNode.rockNodes.count
        levelScore.didTeleport(to: gridPoint, height: floorHeight + rockCount)
    }
}

private extension LevelScore {
    mutating func didEnterScene(at gridPoint: GridPoint, height: Int) {
        heightReached(height)
    }

    mutating func didBuildItem(_ buildableItem: BuildableItem) {
        switch buildableItem {
        case .tree:
            treesBuilt += 1
        case .rock:
            rocksBuilt += 1
        case .synthoid:
            synthoidsBuilt += 1
        }
    }

    mutating func didAbsorbItem(_ absorbableItem: AbsorbableItem) {
        switch absorbableItem {
        case .tree:
            treesAbsorbed += 1
        case .rock:
            rocksAbsorbed += 1
        case .synthoid:
            synthoidsAbsorbed += 1
        case .sentry:
            sentriesAbsorbed += 1
        case .sentinel:
            break // no-op
        }
    }

    mutating func didTeleport(to gridPoint: GridPoint, height: Int) {
        teleports += 1
        heightReached(height)
    }
}
