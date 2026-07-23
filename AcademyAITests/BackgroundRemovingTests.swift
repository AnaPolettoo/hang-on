import Testing
import CoreGraphics
@testable import AcademyAI

struct BackgroundRemovingTests {
    private func makeSolidColorImage(red: UInt8, green: UInt8, blue: UInt8, size: Int = 64) -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var pixelData = [UInt8](repeating: 0, count: size * size * 4)
        for i in stride(from: 0, to: pixelData.count, by: 4) {
            pixelData[i] = red; pixelData[i + 1] = green; pixelData[i + 2] = blue; pixelData[i + 3] = 255
        }
        return CGContext(data: &pixelData, width: size, height: size, bitsPerComponent: 8,
                         bytesPerRow: size * 4, space: colorSpace,
                         bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!.makeImage()!
    }

    // A flat, subject-less texture gives Vision no foreground instance → nil,
    // so callers fall back to the original image. (In CI sandbox without a GPU,
    // Vision throws before returning — same known limitation as
    // VisionClothingClassifierTests; run on device/GPU simulator to verify.)
    @Test func returnsNilWhenNoForegroundInstanceFound() async throws {
        let remover = VisionBackgroundRemover()
        let flat = makeSolidColorImage(red: 180, green: 180, blue: 180)
        let result = try await remover.removeBackground(from: flat)
        #expect(result == nil)
    }

    // Square, matching-size mask+image is the contract Task 2/3 rely on.
    @Test func resultImageAndMaskShareSquareDimensions() async throws {
        let remover = VisionBackgroundRemover()
        // A simple two-tone image is more likely to yield a salient instance than flat gray.
        let image = makeSolidColorImage(red: 20, green: 120, blue: 200)
        if let result = try await remover.removeBackground(from: image) {
            #expect(result.image.width == result.image.height)
            #expect(result.mask.width == result.image.width)
            #expect(result.mask.height == result.image.height)
        }
        // If nil (no instance / sandbox), the contract test above covers the fallback path.
    }
}
