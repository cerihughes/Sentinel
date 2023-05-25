import Madog
import SceneKit
import SnapKit
import UIKit

class LobbyViewController: UIViewController, LobbyViewModelDelegate {
    private let navigationContext: Context
    private let lobbyViewModel: LobbyViewModel
    private let collectionViewLayout = LobbyCollectionViewLayout()

    init(navigationContext: Context, lobbyViewModel: LobbyViewModel) {
        self.navigationContext = navigationContext
        self.lobbyViewModel = lobbyViewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        lobbyViewModel.delegate = self

        configureCollectionViewLayout()

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = lobbyViewModel
        collectionView.delegate = lobbyViewModel

        collectionView.backgroundColor = .black
        collectionView.register(LobbyCollectionViewCell.self, forCellWithReuseIdentifier: lobbyViewModelReuseIdentifier)
        collectionView.decelerationRate = .fast

        view.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.center.width.height.equalToSuperview()
        }
    }

    private func configureCollectionViewLayout() {
        let size = view.frame.size
        let aspectRatio = size.height > 0 ? size.width / size.height : 1.0
        let smallestDimension = min(size.width, size.height)
        var scaled = smallestDimension / 5.0 * 3.0
        if scaled < 100.0 {
            scaled = 100.0
        }

        collectionViewLayout.itemSize = CGSize(width: scaled * aspectRatio, height: scaled)
    }

    // MARK: LobbyViewModelDelegate

    func viewModel(_: LobbyViewModel, didSelect level: Int) {
        navigationContext.show(.gamePreview(level: level))
    }
}
