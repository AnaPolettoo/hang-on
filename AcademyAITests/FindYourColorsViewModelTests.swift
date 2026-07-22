import Testing
import SwiftData
import CoreGraphics
@testable import AcademyAI

private struct FakeFaceRegionDetector: FaceRegionDetecting {
    let regionsToReturn: FaceRegions?
    func detectRegions(in image: CGImage) async throws -> FaceRegions? { regionsToReturn }
}

private struct FakePaletteExplanationGenerator: PaletteExplanationGenerating {
    var stubbedText = "You look great in warm, earthy tones."
    func generateExplanation(season: Season, recommendedColors: [ClosetColor]) async throws -> String { stubbedText }
}

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
        data: &pixelData, width: size, height: size, bitsPerComponent: 8,
        bytesPerRow: bytesPerRow, space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    return context.makeImage()!
}

struct FindYourColorsViewModelTests {
    @Test func processSelfieSavesProfileAndSetsResult() async throws {
        let container = try ModelContainer(for: UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let fullRegion = CGRect(x: 0, y: 0, width: 1, height: 1)
        let detector = FakeFaceRegionDetector(regionsToReturn: FaceRegions(skinRegion: fullRegion, eyeRegion: fullRegion, hairRegion: fullRegion))
        let generator = FakePaletteExplanationGenerator()
        let viewModel = FindYourColorsViewModel(regionDetector: detector, explanationGenerator: generator, modelContext: context)

        let image = makeSolidColorImage(red: 180, green: 100, blue: 70) // warm tone

        await viewModel.processSelfie(image, name: "Ana")

        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.result != nil)
        let saved = try context.fetch(FetchDescriptor<UserColorimetryProfile>())
        #expect(saved.count == 1)
        #expect(saved.first?.name == "Ana")
        #expect(saved.first?.recommendedColors.count == 4)
    }

    @Test func processSelfieSetsErrorWhenNoFaceDetected() async throws {
        let container = try ModelContainer(for: UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let detector = FakeFaceRegionDetector(regionsToReturn: nil)
        let generator = FakePaletteExplanationGenerator()
        let viewModel = FindYourColorsViewModel(regionDetector: detector, explanationGenerator: generator, modelContext: context)
        let image = makeSolidColorImage(red: 0, green: 0, blue: 0)

        await viewModel.processSelfie(image, name: nil)

        #expect(viewModel.result == nil)
        #expect(viewModel.errorMessage != nil)
        let saved = try context.fetch(FetchDescriptor<UserColorimetryProfile>())
        #expect(saved.isEmpty)
    }
}
