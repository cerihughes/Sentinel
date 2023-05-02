import Combine
import SceneKit

protocol GameViewModelDelegate: AnyObject {
    func gameViewModel(_ gameViewModel: GameViewModel, levelDidEndWith state: GameViewModel.EndState)
}

class GameViewModel {
    enum EndState {
        case victory, defeat
    }

    let world: World
    let terrainOperations: TerrainOperations
    let playerOperations: PlayerOperations
    let opponentsOperations: OpponentsOperations
    let synthoidEnergy: SynthoidEnergy = SynthoidEnergyMonitor()
    let gameScore: GameScore
    weak var delegate: GameViewModelDelegate?
    var levelScore = LevelScore()

    private var cancellables: Set<AnyCancellable> = []

    init(levelConfiguration: LevelConfiguration, gameScore: GameScore, nodeFactory: NodeFactory, world: World) {
        self.world = world
        self.gameScore = gameScore

        let tg = TerrainGenerator()
        let grid = tg.generate(levelConfiguration: levelConfiguration)

        let nodeMap = NodeMap()
        let terrainNode = nodeFactory.createTerrainNode(grid: grid, nodeMap: nodeMap)
        world.set(terrainNode: terrainNode)

        let nodeManipulator = NodeManipulator(terrainNode: terrainNode, nodeMap: nodeMap, nodeFactory: nodeFactory)

        terrainOperations = TerrainOperations(grid: grid, nodeManipulator: nodeManipulator)
        playerOperations = PlayerOperations(levelConfiguration: levelConfiguration,
                                            terrainOperations: terrainOperations,
                                            synthoidEnergy: synthoidEnergy,
                                            initialCameraNode: world.initialCameraNode)
        opponentsOperations = OpponentsOperations(
            levelConfiguration: levelConfiguration,
            terrainOperations: terrainOperations
        )
        synthoidEnergy.energyPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: energyUpdated(_:))
            .store(in: &cancellables)
    }

    private func energyUpdated(_ energy: Int) {
        guard energy <= 0 else { return }
        delegate?.gameViewModel(self, levelDidEndWith: .defeat)
    }
}
