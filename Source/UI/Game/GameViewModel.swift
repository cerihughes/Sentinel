import Combine
import SceneKit

protocol GameViewModelDelegate: AnyObject {
    func gameViewModel(_ gameViewModel: GameViewModel, changeCameraNodeTo node: SCNNode)
    func gameViewModel(_ gameViewModel: GameViewModel, levelDidEndWith outcome: LevelScore.Outcome)
}

class GameViewModel {
    let worldBuilder: WorldBuilder
    let built: WorldBuilder.Built
    let inputHandler: SwipeInputHandler
    private let localDataSource: LocalDataSource
    private var gameScore: GameScore
    weak var delegate: GameViewModelDelegate?
    var levelScore = LevelScore()

    private var cancellables: Set<AnyCancellable> = []

    init(worldBuilder: WorldBuilder, localDataSource: LocalDataSource) {
        self.worldBuilder = worldBuilder
        self.localDataSource = localDataSource
        built = worldBuilder.build()
        gameScore = localDataSource.localStorage.gameScore ?? .init()
        let inputHandler = SwipeInputHandler(nodeMap: built.nodeMap, nodeManipulator: built.nodeManipulator)

        built.playerOperations.preAnimationBlock = {
            inputHandler.setGestureRecognisersEnabled(false)
        }

        built.playerOperations.postAnimationBlock = {
            inputHandler.setGestureRecognisersEnabled(true)
        }

        self.inputHandler = inputHandler
        self.inputHandler.delegate = self

        built.synthoidEnergy.energyPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: energyUpdated(_:))
            .store(in: &cancellables)

        built.playerOperations.delegate = self
    }

    func nextNavigationToken() -> Navigation? {
        if levelScore.outcome == .victory {
            // TODO: Need a "success" screen
            return .levelSummary(level: currentLevel + levelScore.nextLevelIncrement)
        }
        // TODO: Need a "game over" screen
        return nil
    }

    private var currentLevel: Int {
        worldBuilder.levelConfiguration.level
    }

    private func energyUpdated(_ energy: Int) {
        guard energy <= 0 else { return }
        endLevelWithOutcome(.defeat)
    }

    private func endLevelWithOutcome(_ outcome: LevelScore.Outcome) {
        levelScore.outcome = outcome
        levelScore.finalEnergy = built.synthoidEnergy.energy
        gameScore.levelScores[worldBuilder.levelConfiguration.level] = levelScore
        localDataSource.localStorage.gameScore = gameScore

        delegate?.gameViewModel(self, levelDidEndWith: outcome)
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
            endLevelWithOutcome(.victory)
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

extension GameViewModel: SwipeInputHandlerDelegate {
    private var playerOperations: PlayerOperations {
        built.playerOperations
    }

    func swipeInputHandlerDidEnterScene(_ swipeInputHandler: SwipeInputHandler) {
        if !playerOperations.hasEnteredScene() {
            _ = playerOperations.enterScene()
        }
    }

    func swipeInputHandler(_ swipeInputHandler: SwipeInputHandler, didMoveToPoint point: GridPoint) {
        playerOperations.move(to: point)
    }

    func swipeInputHandler(_ swipeInputHandler: SwipeInputHandler, didSelectFloorNode floorNode: FloorNode) {
        floorNode.play(positionalSound: .buildStart1)
    }

    func swipeInputHandler(_ swipeInputHandler: SwipeInputHandler, didCancelFloorNode floorNode: FloorNode) {
        floorNode.play(positionalSound: .buildEnd1)
    }

    func swipeInputHandler(
        _ swipeInputHandler: SwipeInputHandler,
        didBuild item: BuildableItem,
        atPoint point: GridPoint,
        rotation: Float?,
        onFloorNode floorNode: FloorNode
    ) {
        floorNode.play(positionalSound: .buildEnd2)
        switch item {
        case .tree:
            playerOperations.buildTree(at: point)
        case .rock:
            playerOperations.buildRock(at: point, rotation: rotation)
        case .synthoid:
            playerOperations.buildSynthoid(at: point)
        }
    }

    func swipeInputHandler(
        _ swipeInputHandler: SwipeInputHandler,
        didAbsorbAtPoint point: GridPoint,
        onFloorNode floorNode: FloorNode
    ) {
        floorNode.play(positionalSound: .buildStart2)
        playerOperations.absorbTopmostNode(at: point)
        floorNode.topmostNode?.removeFromParentNode()
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

    var nextLevelIncrement: Int {
        max(finalEnergy / 4, 1)
    }
}
