import Testing
import CoreGraphics
import ImageIO
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
        let result = try await classifier.classify(image, orientation: .up)
        #expect(abs(result.dominantColor.red - 200.0 / 255.0) < 0.05)
    }

    // Image: left half red (mask white), right half green (mask black).
    // With the mask, dominant color must read red, not the 50/50 average.
    @Test func classifyWithMaskSamplesColorThroughMask() async throws {
        let size = 16
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerRow = size * 4
        func make(_ fill: (Int) -> (UInt8, UInt8, UInt8)) -> CGImage {
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
        let image = make { $0 < size / 2 ? (200, 0, 0) : (0, 200, 0) }
        let mask = make { $0 < size / 2 ? (255, 255, 255) : (0, 0, 0) }

        let classifier = VisionClothingClassifier()
        let result = try await classifier.classify(image, orientation: .up, mask: mask)
        #expect(abs(result.dominantColor.red - 200.0 / 255.0) < 0.05)
        #expect(result.dominantColor.green < 0.05)
    }

    // Skipped in sandboxed/virtualized CI environments without Neural Engine/GPU passthrough
    // (see the file's other tests for the same known limitation) — run on a real device or a
    // GPU-accelerated Simulator.
    @Test func classifyReportsTopConfidenceInValidRange() async throws {
        let classifier = VisionClothingClassifier()
        let image = makeSolidColorImage(red: 200, green: 40, blue: 40)
        let result = try await classifier.classify(image, orientation: .up)
        #expect(result.confidence >= 0 && result.confidence <= 1)
    }
}
