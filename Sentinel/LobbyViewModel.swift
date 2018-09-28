import Foundation
import UIKit

let lobbyViewModelReuseIdentifier = "lobbyViewModelReuseIdentifier"

class LobbyViewModel: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: lobbyViewModelReuseIdentifier, for: indexPath) as! LobbyCollectionViewCell
        let cellViewModel = createCellViewModel(for: indexPath)
        cell.sceneView.scene = cellViewModel.world.scene
        return cell
    }

    private func createCellViewModel(for indexPath: IndexPath) -> LobbyCellViewModel {
        let levelConfiguration = MainLevelConfiguration(level: indexPath.row)
        let nodePositioning = NodePositioning(gridWidth: levelConfiguration.gridWidth,
                                              gridDepth: levelConfiguration.gridDepth,
                                              floorSize: floorSize)
        let nodeFactory = NodeFactory(nodePositioning: nodePositioning,
                                      detectionRadius: levelConfiguration.opponentDetectionRadius * floorSize)

        let world = SpaceWorld(nodeFactory: nodeFactory)
        return LobbyCellViewModel(levelConfiguration: levelConfiguration, nodeFactory: nodeFactory, world: world)
    }

}
