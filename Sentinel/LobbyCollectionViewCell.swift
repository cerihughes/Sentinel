import SceneKit
import UIKit

class LobbyCollectionViewCell: UICollectionViewCell {
    let sceneView: SCNView

    override init(frame: CGRect) {
        sceneView = SCNView(frame: frame)
        sceneView.backgroundColor = UIColor.clear
        super.init(frame: frame)

        sceneView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sceneView)

        let mainCenterX = sceneView.centerXAnchor.constraint(equalTo: centerXAnchor)
        let mainCenterY = sceneView.centerYAnchor.constraint(equalTo: centerYAnchor)
        let mainWidth = sceneView.widthAnchor.constraint(equalTo: widthAnchor)
        let mainHeight = sceneView.heightAnchor.constraint(equalTo: heightAnchor)

        NSLayoutConstraint.activate([mainCenterX, mainCenterY, mainWidth, mainHeight])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
