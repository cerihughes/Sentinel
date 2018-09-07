import UIKit

class SkyBox: NSObject {
    let sourceImage: UIImage

    init(sourceImage: UIImage) {
        self.sourceImage = sourceImage

        super.init()
    }

    func componentImages() -> [UIImage]? {
        let size = sourceImage.size
        let scale = sourceImage.scale
        let componentWidth = size.width / 4.0 * scale
        let componentHeight = size.height / 3.0 * scale
        guard componentWidth == componentHeight else {
            return nil
        }

        var images: [UIImage] = []
        crop(x: 2, y: 1, dimension: componentWidth, into: &images) // Right
        crop(x: 0, y: 1, dimension: componentWidth, into: &images) // Left
        crop(x: 1, y: 0, dimension: componentWidth, into: &images) // Top
        crop(x: 1, y: 2, dimension: componentWidth, into: &images) // Bottom
        crop(x: 1, y: 1, dimension: componentWidth, into: &images) // Back
        crop(x: 3, y: 1, dimension: componentWidth, into: &images) // Front
        return images
    }

    private func crop(x: Int, y: Int, dimension: CGFloat, into images: inout [UIImage]) {
        let origin = CGPoint(x: CGFloat(x) * dimension , y: CGFloat(y) * dimension)
        let size = CGSize(width: dimension, height: dimension)
        let rect = CGRect(origin: origin, size: size)
        if let image = crop(rect: rect) {
            images.append(image)
        }
    }

    // y = 0 is at the top
    private func crop(rect: CGRect) -> UIImage? {
        guard let cgImage = sourceImage.cgImage?.cropping(to: rect) else {
            return nil
        }

        return UIImage(cgImage:cgImage)
    }
}
