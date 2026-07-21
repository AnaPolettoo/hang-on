import Testing
import CoreGraphics
@testable import AcademyAI

struct FaceRegionDetectingTests {
    private func makeSolidColorImage(size: Int = 32) -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * size
        var pixelData = [UInt8](repeating: 10, count: size * size * bytesPerPixel)
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

    @Test func returnsNilWhenNoFaceIsPresent() async throws {
        let detector = VisionFaceRegionDetector()
        let image = makeSolidColorImage()
        let regions = try await detector.detectRegions(in: image)
        #expect(regions == nil)
    }
}
