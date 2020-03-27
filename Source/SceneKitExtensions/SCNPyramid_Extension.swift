import SceneKit

extension SCNPyramid {
    convenience init(hFOV hDegrees: CGFloat, vFOV vDegrees: CGFloat, zFar: CGFloat) {
        let baseWidth = 2.0 * SCNPyramid.oppositeSideLengthFrom(adjacentSideLength: zFar, angle: hDegrees / 2.0)
        let baseHeight = 2.0 * SCNPyramid.oppositeSideLengthFrom(adjacentSideLength: zFar, angle: vDegrees / 2.0)
        self.init(width: baseWidth, height: zFar, length: baseHeight)
    }

    convenience init(hFOV hDegrees: CGFloat, aspectRatio: CGFloat, zFar: CGFloat) {
        let vDegrees = hDegrees / aspectRatio
        self.init(hFOV: hDegrees, vFOV: vDegrees, zFar: zFar)
    }

    private static func oppositeSideLengthFrom(adjacentSideLength: CGFloat, angle degrees: CGFloat) -> CGFloat {
        let radians = degrees * CGFloat.pi / 180.0
        return tan(radians) * adjacentSideLength
    }
}
