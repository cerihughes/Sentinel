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
    private let localDataSource: LocalDataSource
    private let gameScore: GameScore
    weak var delegate: GameViewModelDelegate?
    var levelScore = LevelScore()

    private var cancellables: Set<AnyCancellable> = []

    init(worldBuilder: WorldBuilder, localDataSource: LocalDataSource) {
        self.worldBuilder = worldBuilder
        self.localDataSource = localDataSource
        built = worldBuilder.build()
        gameScore = localDataSource.localStorage.gameScore ?? .init()

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

    func playerOperations(_ playerOperations: PlayerOperations, didPerform operation: PlayerOperations.Operation) {
        switch operation {
        case .enterScene(let gridPoint):
            playerOperationsDidEnterScene(at: gridPoint)
            built.timeMachine.start()
        case .build(let buildableItem):
            playerOperationsDidBuild(buildableItem)
        case .absorb(let absorbableItem):
            playerOperationsDidAbsorb(absorbableItem)
        case .teleport(let gridPoint):
            playerOperationsDidTeleport(to: gridPoint)
        }
    }

    private func playerOperationsDidEnterScene(at gridPoint: GridPoint) {
        guard let piece = built.grid.piece(at: gridPoint), piece.isFloor else { return }
        let floorHeight = Int(piece.level)
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
            let floorNode = built.nodeMap.floorNode(at: gridPoint),
            let piece = built.grid.piece(at: gridPoint),
            piece.isFloor
        else {
            return
        }

        let rockCount = floorNode.rockNodes.count
        let rockHeight = Float(rockCount) * 0.5
        let floorHeight = Int(piece.level + rockHeight)
        levelScore.didTeleport(to: gridPoint, height: floorHeight)
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
