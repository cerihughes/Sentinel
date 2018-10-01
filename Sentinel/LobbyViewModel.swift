import Foundation
import UIKit

let lobbyViewModelReuseIdentifier = "lobbyViewModelReuseIdentifier"

protocol LobbyViewModelDelegate: class {
    func viewModel(_: LobbyViewModel, didSelect level: Int)
}

class LobbyViewModel: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    private let sceneImageLoader = SceneImageLoader()

    weak var delegate: LobbyViewModelDelegate?

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: lobbyViewModelReuseIdentifier, for: indexPath) as! LobbyCollectionViewCell
        var size = collectionView.frame.size
        if let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            size = collectionViewLayout.itemSize
        }
        sceneImageLoader.loadImage(level: indexPath.row, size: size) { (image) in
            cell.imageView.image = image
        }
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate = delegate else {
            return
        }

        delegate.viewModel(self, didSelect: indexPath.row)
    }
}
