import UIKit

class LobbyCollectionViewLayout: UICollectionViewLayout {
    var itemSize: CGSize = .zero

    private let peekOffsetPercentage: CGFloat = 0.05

    private var cache = [UICollectionViewLayoutAttributes]()

    // MARK: UICollectionViewLayout

    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return .zero
        }

        let numberOfItems = collectionView.numberOfItems(inSection: 0)

        let contentWidth = (itemSize.width * CGFloat(numberOfItems)) + (spacing * CGFloat(numberOfItems + 2)) + (peekOffset * 2.0)
        let contentHeight = collectionView.bounds.height
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        guard let collectionView = collectionView else {
            return
        }

        cache.removeAll(keepingCapacity: false)

        let y: CGFloat = (collectionView.bounds.height - itemSize.height) / 2.0
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        for item in 0 ..< numberOfItems {
            let x = xPosition(for: item)
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

            let frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
            print(frame)
            attributes.frame = frame
            cache.append(attributes)
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let offset = peekOffset + spacing
        let width = itemSize.width + spacing
        let x = proposedContentOffset.x
        let indexFloat = CGFloat(x) / width
        let index = Int(indexFloat.rounded())
        return CGPoint(x: xPosition(for: index) - offset, y: proposedContentOffset.y)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }

    // MARK: Private

    private func xPosition(for itemIndex: Int) -> CGFloat {
        let width = itemSize.width + spacing
        return peekOffset + spacing + (CGFloat(itemIndex) * width)
    }

    private var peekOffset: CGFloat {
        guard let collectionView = collectionView else {
            return 0.0
        }

        return collectionView.bounds.width * peekOffsetPercentage
    }

    private var spacing: CGFloat {
        guard let collectionView = collectionView else {
            return 0.0
        }

        let spacing = collectionView.bounds.width - itemSize.width - (peekOffset * 2.0)
        return spacing / 2.0
    }
}
