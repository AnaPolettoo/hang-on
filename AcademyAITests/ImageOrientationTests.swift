import Testing
import CoreGraphics
import ImageIO
@testable import AcademyAI

struct ImageOrientationTests {
    // Top-left is red, everything else blue. After a `.right` orientation
    // (90° CW as Vision/ImageIO interpret it), the original top-left quadrant
    // must no longer be at the output's top-left.
    private func makeQuadrantImage(size: Int = 16) -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerRow = size * 4
        var pixelData = [UInt8](repeating: 0, count: size * size * 4)
        for row in 0..<size {
            for col in 0..<size {
                let offset = row * bytesPerRow + col * 4
                let isTopLeft = row < size / 2 && col < size / 2
                pixelData[offset] = isTopLeft ? 255 : 0
                pixelData[offset + 1] = 0
                pixelData[offset + 2] = isTopLeft ? 0 : 255
                pixelData[offset + 3] = 255
            }
        }
        return CGContext(data: &pixelData, width: size, height: size, bitsPerComponent: 8,
                         bytesPerRow: bytesPerRow, space: colorSpace,
                         bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!.makeImage()!
    }

    private func topLeftPixel(of image: CGImage) -> (UInt8, UInt8, UInt8) {
        let w = image.width, h = image.height
        var data = [UInt8](repeating: 0, count: w * h * 4)
        let ctx = CGContext(data: &data, width: w, height: h, bitsPerComponent: 8,
                            bytesPerRow: w * 4, space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
        return (data[0], data[1], data[2]) // top-left pixel (row 0, col 0)
    }

    @Test func uprightWithUpOrientationReturnsSameImage() {
        let image = makeQuadrantImage()
        let result = ImageOrientation.upright(image, orientation: .up)
        #expect(result.width == image.width)
        // top-left stays red
        let (r, _, b) = topLeftPixel(of: result)
        #expect(r > 200 && b < 60)
    }

    @Test func uprightRotatesPixelsForNonUpOrientation() {
        let image = makeQuadrantImage()
        let result = ImageOrientation.upright(image, orientation: .right)
        // After baking a rotation, the red quadrant is no longer at top-left.
        let (r, _, b) = topLeftPixel(of: result)
        #expect(!(r > 200 && b < 60))
    }
}
