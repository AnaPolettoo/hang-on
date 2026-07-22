import Testing
import CoreGraphics
@testable import AcademyAI

struct VisionClothingClassifierTests {
    private func makeSolidColorImage(red: UInt8, green: UInt8, blue: UInt8, size: Int = 32) -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var pixelData = [UInt8](repeating: 0, count: size * size * 4)
        for i in stride(from: 0, to: pixelData.count, by: 4) {
            pixelData[i] = red
            pixelData[i + 1] = green
            pixelData[i + 2] = blue
            pixelData[i + 3] = 255
        }
        let context = CGContext(
            data: &pixelData, width: size, height: size, bitsPerComponent: 8,
            bytesPerRow: size * 4, space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        return context.makeImage()!
    }

    // Skipped in sandboxed/virtualized CI environments without Neural Engine/GPU
    // passthrough: Vision throws "Could not create inference context" (Domain
    // com.apple.Vision Code=9) before this can even assert. Run on a real device
    // or a properly GPU-accelerated Simulator to verify (see FaceRegionDetectingTests
    // for the same known limitation).
    @Test func classifyReturnsDominantColorSampledFromImage() async throws {
        let classifier = VisionClothingClassifier()
        let image = makeSolidColorImage(red: 200, green: 40, blue: 40)
        let result = try await classifier.classify(image)
        #expect(abs(result.dominantColor.red - 200.0 / 255.0) < 0.05)
    }
}
