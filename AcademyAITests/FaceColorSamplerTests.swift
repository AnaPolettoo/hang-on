import Testing
import CoreGraphics
@testable import AcademyAI

struct FaceColorSamplerTests {
    private func makeSolidColorImage(red: UInt8, green: UInt8, blue: UInt8, size: Int = 8) -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * size
        var pixelData = [UInt8](repeating: 0, count: size * size * bytesPerPixel)
        for i in stride(from: 0, to: pixelData.count, by: 4) {
            pixelData[i] = red
            pixelData[i + 1] = green
            pixelData[i + 2] = blue
            pixelData[i + 3] = 255
        }
        let context = CGContext(
            data: &pixelData,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        return context.makeImage()!
    }

    /// Builds a synthetic image split into quadrants: top-left is `topLeft`, everything
    /// else is `otherwise`. Used to pin down the region's coordinate convention (a
    /// wrong origin or an axis flip would sample the wrong quadrant's color).
    private func makeQuadrantImage(topLeft: (UInt8, UInt8, UInt8), otherwise: (UInt8, UInt8, UInt8), size: Int = 16) -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * size
        var pixelData = [UInt8](repeating: 0, count: size * size * bytesPerPixel)
        for row in 0..<size {
            for col in 0..<size {
                let offset = row * bytesPerRow + col * bytesPerPixel
                let color = (row < size / 2 && col < size / 2) ? topLeft : otherwise
                pixelData[offset] = color.0
                pixelData[offset + 1] = color.1
                pixelData[offset + 2] = color.2
                pixelData[offset + 3] = 255
            }
        }
        let context = CGContext(
            data: &pixelData,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        return context.makeImage()!
    }

    @Test func averageColorSamplesCorrectQuadrantNotItsOpposite() {
        // Top-left quadrant is red, everything else (including bottom-right) is blue.
        let image = makeQuadrantImage(topLeft: (255, 0, 0), otherwise: (0, 0, 255))

        let topLeftRegion = FaceColorSampler.averageColor(in: image, region: CGRect(x: 0, y: 0, width: 0.5, height: 0.5))
        #expect(abs(topLeftRegion.red - 1.0) < 0.02)
        #expect(abs(topLeftRegion.green - 0.0) < 0.02)
        #expect(abs(topLeftRegion.blue - 0.0) < 0.02)

        let bottomRightRegion = FaceColorSampler.averageColor(in: image, region: CGRect(x: 0.5, y: 0.5, width: 0.5, height: 0.5))
        #expect(abs(bottomRightRegion.red - 0.0) < 0.02)
        #expect(abs(bottomRightRegion.green - 0.0) < 0.02)
        #expect(abs(bottomRightRegion.blue - 1.0) < 0.02)

        let topRightRegion = FaceColorSampler.averageColor(in: image, region: CGRect(x: 0.5, y: 0, width: 0.5, height: 0.5))
        #expect(abs(topRightRegion.red - 0.0) < 0.02)
        #expect(abs(topRightRegion.blue - 1.0) < 0.02)

        let bottomLeftRegion = FaceColorSampler.averageColor(in: image, region: CGRect(x: 0, y: 0.5, width: 0.5, height: 0.5))
        #expect(abs(bottomLeftRegion.red - 0.0) < 0.02)
        #expect(abs(bottomLeftRegion.blue - 1.0) < 0.02)
    }

    @Test func averageColorOfSolidRedImageIsRed() {
        let image = makeSolidColorImage(red: 200, green: 20, blue: 20)
        let color = FaceColorSampler.averageColor(in: image, region: CGRect(x: 0, y: 0, width: 1, height: 1))
        #expect(abs(color.red - 200.0 / 255.0) < 0.02)
        #expect(abs(color.green - 20.0 / 255.0) < 0.02)
        #expect(abs(color.blue - 20.0 / 255.0) < 0.02)
    }

    @Test func averageColorOfSubRegionMatchesFullImageWhenSolid() {
        let image = makeSolidColorImage(red: 100, green: 150, blue: 200)
        let full = FaceColorSampler.averageColor(in: image, region: CGRect(x: 0, y: 0, width: 1, height: 1))
        let quarter = FaceColorSampler.averageColor(in: image, region: CGRect(x: 0.25, y: 0.25, width: 0.25, height: 0.25))
        #expect(abs(full.red - quarter.red) < 0.02)
        #expect(abs(full.green - quarter.green) < 0.02)
        #expect(abs(full.blue - quarter.blue) < 0.02)
    }

    // Left half foreground (mask white), right half background (mask black).
    // Image: left half red, right half green. Masked average must be pure red.
    @Test func averageColorWithMaskIgnoresBackgroundPixels() {
        let size = 16
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerRow = size * 4

        func makeImage(_ fill: (Int) -> (UInt8, UInt8, UInt8)) -> CGImage {
            var data = [UInt8](repeating: 0, count: size * size * 4)
            for row in 0..<size {
                for col in 0..<size {
                    let o = row * bytesPerRow + col * 4
                    let (r, g, b) = fill(col)
                    data[o] = r; data[o + 1] = g; data[o + 2] = b; data[o + 3] = 255
                }
            }
            return CGContext(data: &data, width: size, height: size, bitsPerComponent: 8,
                             bytesPerRow: bytesPerRow, space: colorSpace,
                             bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!.makeImage()!
        }

        let image = makeImage { col in col < size / 2 ? (200, 0, 0) : (0, 200, 0) }
        let mask = makeImage { col in col < size / 2 ? (255, 255, 255) : (0, 0, 0) }

        let color = FaceColorSampler.averageColor(in: image, mask: mask)
        #expect(abs(color.red - 200.0 / 255.0) < 0.05)
        #expect(color.green < 0.05)
    }
}
