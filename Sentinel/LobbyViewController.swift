import SceneKit
import UIKit

class LobbyViewController: UIViewController, LobbyViewModelDelegate {
    private let ui: UIContext
    private let lobbyViewModel: LobbyViewModel
    private let collectionViewLayout = LobbyCollectionViewLayout()

    init(ui: UIContext, lobbyViewModel: LobbyViewModel) {
        self.ui = ui
        self.lobbyViewModel = lobbyViewModel

        super.init(nibName: nil, bundle: nil)
    }
    
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

        collectionView.register(LobbyCollectionViewCell.self, forCellWithReuseIdentifier: lobbyViewModelReuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.decelerationRate = .fast

        view.addSubview(collectionView)

        let mainCenterX = collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let mainCenterY = collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let mainWidth = collectionView.widthAnchor.constraint(equalTo: view.widthAnchor)
        let mainHeight = collectionView.heightAnchor.constraint(equalTo: view.heightAnchor)

        NSLayoutConstraint.activate([mainCenterX, mainCenterY, mainWidth, mainHeight])
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
        let rl = RegistrationLocator(identifier: levelSummaryIdentifier, level: level)
        _ = ui.navigate(with: rl, animated: true)
    }
}
