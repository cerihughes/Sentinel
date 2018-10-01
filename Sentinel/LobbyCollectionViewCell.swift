import UIKit

class LobbyCollectionViewCell: UICollectionViewCell {
    var terrainIndex: Int = -1
    let imageView: UIImageView

    override init(frame: CGRect) {
        imageView = UIImageView(frame: frame)
        super.init(frame: frame)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        let mainCenterX = imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        let mainCenterY = imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        let mainWidth = imageView.widthAnchor.constraint(equalTo: widthAnchor)
        let mainHeight = imageView.heightAnchor.constraint(equalTo: heightAnchor)

        NSLayoutConstraint.activate([mainCenterX, mainCenterY, mainWidth, mainHeight])
    }

    override func prepareForReuse() {
        terrainIndex = -1
        imageView.image = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
