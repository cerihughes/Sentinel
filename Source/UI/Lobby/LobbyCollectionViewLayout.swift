import UIKit

class LobbyCollectionViewLayout: UICollectionViewLayout {
    var itemSize: CGSize = .zero

    private var collectionViewSize: CGSize = .zero
    private var collectionViewContentOffset = CGPoint(x: 0, y: 0)

    private let peekOffsetPercentage: CGFloat = 0.1
    private let itemShrinkPercentage: CGFloat = 0.2

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

        collectionViewSize = collectionView.bounds.size
        collectionViewContentOffset = collectionView.contentOffset

        cache.removeAll(keepingCapacity: false)

        let y: CGFloat = (collectionViewSize.height - itemSize.height) / 2.0
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        for i in 0 ..< numberOfItems {
            let x = xPosition(for: i)
            let indexPath = IndexPath(item: i, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

            let size = adjustedItemSizeForContentOffset(at: i)
            let adjustedX = x + ((itemSize.width - size.width) / 2.0)
            let adjustedY = y + ((itemSize.height - size.height) / 2.0)
            let frame = CGRect(x: adjustedX, y: adjustedY, width: size.width, height: size.height)
            attributes.frame = frame
            cache.append(attributes)
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        cache.filter { $0.frame.intersects(rect) }
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let offset = peekOffset + spacing
        let width = itemSize.width + spacing
        let x = proposedContentOffset.x
        let indexFloat = x / width
        let index = Int(indexFloat.rounded())
        return CGPoint(x: xPosition(for: index) - offset, y: proposedContentOffset.y)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    // MARK: Private

    private var peekOffset: CGFloat {
        return collectionViewSize.width * peekOffsetPercentage
    }

    private var spacing: CGFloat {
        let spacing = collectionViewSize.width - itemSize.width - (peekOffset * 2.0)
        return spacing / 2.0
    }

    private func xPosition(for itemIndex: Int) -> CGFloat {
        let width = itemSize.width + spacing
        return peekOffset + spacing + (CGFloat(itemIndex) * width)
    }

    private func adjustedItemSizeForContentOffset(at index: Int) -> CGSize {
        let width = itemSize.width + spacing
        let x = collectionViewContentOffset.x
        let scaled = x / width

        var delta = abs(CGFloat(index) - scaled)
        if delta > 1.0 {
            delta = 1.0
        }

        delta *= itemShrinkPercentage

        var size = itemSize
        size.width *= (1.0 - delta)
        size.height *= (1.0 - delta)

        return size
    }
}
