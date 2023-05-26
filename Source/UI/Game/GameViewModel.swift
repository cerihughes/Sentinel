import Combine
import SceneKit

protocol GameViewModelDelegate: AnyObject {
    func gameViewModel(_ gameViewModel: GameViewModel, changeCameraNodeTo node: SCNNode)
    func gameViewModel(_ gameViewModel: GameViewModel, levelDidEndWith outcome: LevelScore.Outcome)
}

class GameViewModel {
    private let level: Int
    let terrain: WorldBuilder.Terrain
    let operations: WorldBuilder.Operations
    let inputHandler: SwipeInputHandler
    private let localDataSource: LocalDataSource
    private let audioManager: AudioManager
    private var gameScore: GameScore
    weak var delegate: GameViewModelDelegate?
    var levelScore = LevelScore()

    private var cancellables: Set<AnyCancellable> = []

    init(level: Int, worldBuilder: WorldBuilder, localDataSource: LocalDataSource, audioManager: AudioManager) {
        self.level = level
        self.localDataSource = localDataSource
        self.audioManager = audioManager
        terrain = worldBuilder.buildTerrain()
        operations = terrain.createOperations()
        gameScore = localDataSource.localStorage.gameScore ?? .init()
        let inputHandler = terrain.createInputHandler()

        operations.playerOperations.preAnimationBlock = {
            inputHandler.setGestureRecognisersEnabled(false)
        }

        operations.playerOperations.postAnimationBlock = {
            inputHandler.setGestureRecognisersEnabled(true)
        }

        self.inputHandler = inputHandler
        self.inputHandler.delegate = self

        operations.synthoidEnergy.energyPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: energyUpdated(_:))
            .store(in: &cancellables)

        operations.playerOperations.delegate = self
    }

    func nextNavigationToken() -> Navigation? {
        if levelScore.outcome == .victory {
            return .gameSummary(level: level)
        }
        // TODO: Need a "game over" screen
        return nil
    }

    private func energyUpdated(_ energy: Int) {
        guard energy <= 0 else { return }
        endLevelWithOutcome(.defeat)
    }

    private func endLevelWithOutcome(_ outcome: LevelScore.Outcome) {
        levelScore.outcome = outcome
        levelScore.finalEnergy = operations.synthoidEnergy.energy
        gameScore.levelScores[level] = levelScore
        localDataSource.localStorage.gameScore = gameScore

        audioManager.play(soundFile: outcome.soundFile)
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
            operations.timeMachine.start()
        case .build(let buildableItem):
            playerOperationsDidBuild(buildableItem)
        case .absorb(let absorbableItem):
            playerOperationsDidAbsorb(absorbableItem)
        case .teleport(let gridPoint):
            playerOperationsDidTeleport(to: gridPoint)
        }
    }

    private func playerOperationsDidEnterScene(at gridPoint: GridPoint) {
        guard let piece = terrain.terrainOperations.grid.piece(at: gridPoint), piece.isFloor else { return }
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
            let floorNode = terrain.nodeMap.floorNode(at: gridPoint),
            let piece = terrain.terrainOperations.grid.piece(at: gridPoint),
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

extension GameViewModel: InputHandlerDelegate {
    private var playerOperations: PlayerOperations {
        operations.playerOperations
    }

    func inputHandlerDidEnterScene(_ inputHandler: InputHandler) {
        if !playerOperations.hasEnteredScene() {
            playerOperations.enterScene()
        }
    }

    func inputHandler(_ inputHandler: InputHandler, didPan pan: Pan) {
        let deltaXDegrees = pan.deltaX / 10.0
        let deltaXRadians = deltaXDegrees * Float.pi / 180.0
        let deltaYDegrees = pan.deltaY / 10.0
        let deltaYRadians = deltaYDegrees * Float.pi / 180.0
        terrain.nodeManipulator.rotateCurrentSynthoid(
            rotationDelta: deltaXRadians,
            elevationDelta: deltaYRadians,
            persist: pan.finished
        )
    }

    func inputHandler(_ inputHandler: InputHandler, didMoveToPoint point: GridPoint) {
        guard let floorNode = terrain.nodeMap.floorNode(at: terrain.terrainOperations.grid.currentPosition) else {
            return
        }
        floorNode.play(soundFile: .teleport)
        playerOperations.move(to: point)
    }

    func inputHandler(_ inputHandler: InputHandler, didSelectFloorNode floorNode: FloorNode) {
        floorNode.play(soundFile: .buildStart1)
    }

    func inputHandler(_ inputHandler: InputHandler, didCancelFloorNode floorNode: FloorNode) {
        floorNode.play(soundFile: .buildEnd1)
    }

    func inputHandler(
        _ inputHandler: InputHandler,
        didBuild item: BuildableItem,
        atPoint point: GridPoint,
        rotation: Float?,
        onFloorNode floorNode: FloorNode
    ) {
        floorNode.play(soundFile: .buildEnd2)
        switch item {
        case .tree:
            playerOperations.buildTree(at: point)
        case .rock:
            playerOperations.buildRock(at: point, rotation: rotation)
        case .synthoid:
            playerOperations.buildSynthoid(at: point)
        }
    }

    func inputHandler(
        _ inputHandler: InputHandler,
        didAbsorbAtPoint point: GridPoint,
        onFloorNode floorNode: FloorNode
    ) {
        floorNode.play(soundFile: .buildStart2)
        playerOperations.absorbTopmostNode(at: point)
    }
}

private extension WorldBuilder.Terrain {
    func createInputHandler() -> SwipeInputHandler {
        .init(nodeMap: nodeMap, nodeFactory: nodeFactory, rootNode: terrainNode)
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

private extension LevelScore.Outcome {
    var soundFile: SoundFile {
        switch self {
        case .victory:
            return .levelEnd
        case .defeat:
            return .absorbed
        }
    }
}
