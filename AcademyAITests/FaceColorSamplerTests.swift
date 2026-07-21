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
}
