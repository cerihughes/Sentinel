import Foundation
import UIKit

private let imageLoadThreshold: TimeInterval = 0.1

let lobbyViewModelReuseIdentifier = "lobbyViewModelReuseIdentifier"

protocol LobbyViewModelDelegate: AnyObject {
    func viewModel(_: LobbyViewModel, didSelect level: Int)
}

class LobbyViewModel: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    private let sceneImageLoader = SceneImageLoader()
    private var sceneImageLoaderTokens: [IndexPath: SceneImageLoaderToken] = [:]

    weak var delegate: LobbyViewModelDelegate?

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: lobbyViewModelReuseIdentifier, for: indexPath)
    }

    // MARK: UICollectionViewDelegate

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let cell = cell as? LobbyCollectionViewCell else { return }
        let level = indexPath.row
        var size = collectionView.frame.size
        if let collectionViewLayout = collectionView.collectionViewLayout as? LobbyCollectionViewLayout {
            size = collectionViewLayout.itemSize
        }

        cell.terrainIndex = level

        let token = sceneImageLoader.loadImage(level: level, size: size) { image, timeInterval in
            if cell.terrainIndex == level {
                let duration = (timeInterval < imageLoadThreshold) ? 0.0 : 0.3
                UIView.transition(with: cell.imageView,
                                  duration: duration,
                                  options: .transitionCrossDissolve,
                                  animations: { cell.imageView.image = image },
                                  completion: nil)
            }
            self.sceneImageLoaderTokens.removeValue(forKey: indexPath)
        }
        sceneImageLoaderTokens[indexPath] = token
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        sceneImageLoaderTokens[indexPath]?.cancel()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate = delegate else {
            return
        }

        delegate.viewModel(self, didSelect: indexPath.row)
    }
}
