import UIKit

struct UIImagePattern: Pattern {
    private let image: UIImage

    init(image: UIImage) {
        self.image = image
    }

    var width: Int { image.pixelWidth }
    var depth: Int { image.pixelHeight }

    func level(at point: GridPoint) -> Int {
        image.hasPixel(x: point.x, y: point.z) ? 1 : 0
    }
}

extension UIImage {
    static func create(text: String, font: UIFont = .monospacedDigitSystemFont(ofSize: 16, weight: .bold)) -> UIImage? {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: font
        ]
        let textSize = text.size(withAttributes: attributes)

        UIGraphicsBeginImageContextWithOptions(textSize, true, 2)
        let rect = CGRect(origin: .zero, size: textSize)
        text.draw(in: rect, withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}

// Adapted from https://stackoverflow.com/questions/3284185/get-pixel-color-of-uiimage with thanks!
private extension UIImage {
    var pixelWidth: Int { cgImage?.width ?? 0 }
    var pixelHeight: Int { cgImage?.height ?? 0 }

    func hasPixel(x: Int, y: Int) -> Bool {
        guard let cgImage else { return false }
        return cgImage.hasPixel(x: x, y: y)
    }
}

private extension CGImage {
    func hasPixel(x: Int, y: Int) -> Bool {
        guard
            0 ..< width ~= x && 0 ..< height ~= y,
            let data = dataProvider?.data,
            let dataPtr = CFDataGetBytePtr(data),
            let colorSpaceModel = colorSpace?.model,
            let componentLayout = bitmapInfo.componentLayout,
            colorSpaceModel == .rgb,
            bitsPerPixel == 32 || bitsPerPixel == 24
        else {
            return false
        }

        let pixelOffset = y * bytesPerRow + x * bitsPerPixel / 8

        // Assumption: The pixels we want to "draw" are white, so we just need to check that the red value is large
        let red = dataPtr[pixelOffset + componentLayout.redOffset]
        return red > 255 / 3
    }
}

private extension CGBitmapInfo {
    enum ComponentLayout {
        case bgra
        case abgr
        case argb
        case rgba
        case bgr
        case rgb

        var redOffset: Int {
            switch self {
            case .bgra, .bgr:
                return 2
            case .abgr:
                return 3
            case .argb:
                return 1
            case .rgba, .rgb:
                return 0
            }
        }
    }

    var componentLayout: ComponentLayout? {
        guard let alphaInfo = CGImageAlphaInfo(rawValue: rawValue & Self.alphaInfoMask.rawValue) else { return nil }
        let isLittleEndian = contains(.byteOrder32Little)

        if alphaInfo == .none {
            return isLittleEndian ? .bgr : .rgb
        }
        let alphaIsFirst = alphaInfo == .premultipliedFirst || alphaInfo == .first || alphaInfo == .noneSkipFirst

        if isLittleEndian {
            return alphaIsFirst ? .bgra : .abgr
        } else {
            return alphaIsFirst ? .argb : .rgba
        }
    }
}
