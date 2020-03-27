import SnapKit
import UIKit

class LobbyCollectionViewCell: UICollectionViewCell {
    var terrainIndex: Int = -1
    let imageView: UIImageView

    override init(frame: CGRect) {
        imageView = UIImageView(frame: frame)
        super.init(frame: frame)

        addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.center.width.height.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        terrainIndex = -1
        imageView.image = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
