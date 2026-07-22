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

    // Skipped in sandboxed/virtualized CI environments without Neural Engine/GPU
    // passthrough: Vision throws "Could not create inference context" (Domain
    // com.apple.Vision Code=9) before this can even assert. Run on a real device
    // or a properly GPU-accelerated Simulator to verify (see Task 12's manual
    // verification step in the plan).
    @Test func returnsNilWhenNoFaceIsPresent() async throws {
        let detector = VisionFaceRegionDetector()
        let image = makeSolidColorImage()
        let regions = try await detector.detectRegions(in: image)
        #expect(regions == nil)
    }
}
