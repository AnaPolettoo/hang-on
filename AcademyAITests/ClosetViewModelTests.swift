// AcademyAI/AcademyAITests/ClosetViewModelTests.swift
import Foundation
import Testing
import SwiftData
import CoreGraphics
import ImageIO
@testable import AcademyAI

private struct FakeClothingClassifier: ClothingClassifying {
    let result: ClothingClassification
    func classify(_ image: CGImage, orientation: CGImagePropertyOrientation, mask: CGImage? = nil) async throws -> ClothingClassification { result }
}

private struct FailingClothingClassifier: ClothingClassifying {
    struct TestError: Error {}
    func classify(_ image: CGImage, orientation: CGImagePropertyOrientation, mask: CGImage? = nil) async throws -> ClothingClassification { throw TestError() }
}

private struct StubBackgroundRemover: BackgroundRemoving {
    let result: BackgroundRemovalResult?
    func removeBackground(from image: CGImage) async throws -> BackgroundRemovalResult? { result }
}

private func makeSolidColorImage(size: Int = 8) -> CGImage {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    var pixelData = [UInt8](repeating: 0, count: size * size * 4)
    for i in stride(from: 0, to: pixelData.count, by: 4) {
        pixelData[i] = 200
        pixelData[i + 1] = 100
        pixelData[i + 2] = 90
        pixelData[i + 3] = 255
    }
    let context = CGContext(
        data: &pixelData, width: size, height: size, bitsPerComponent: 8,
        bytesPerRow: size * 4, space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    return context.makeImage()!
}

@MainActor
struct ClosetViewModelTests {
    @Test func processPhotoReturnsClassificationWithoutSaving() async throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let classifier = FakeClothingClassifier(result: ClothingClassification(category: .tops, dominantColor: .lime))
        let viewModel = ClosetViewModel(classifier: classifier, backgroundRemover: StubBackgroundRemover(result: nil), modelContext: ModelContext(container))

        let result = await viewModel.processPhoto(makeSolidColorImage(), orientation: .up)

        #expect(result?.classification.category == .tops)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.items.isEmpty)
    }

    @Test func processPhotoFallsBackToOriginalImageWhenNoBackgroundRemoved() async throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let classifier = FakeClothingClassifier(result: ClothingClassification(category: .tops, dominantColor: .lime))
        let viewModel = ClosetViewModel(classifier: classifier, backgroundRemover: StubBackgroundRemover(result: nil), modelContext: ModelContext(container))
        let original = makeSolidColorImage()

        let result = await viewModel.processPhoto(original, orientation: .up)

        // Removal returned nil → the processed image is the (upright) original.
        #expect(result?.image.width == original.width)
    }

    @Test func processPhotoSetsErrorMessageOnClassificationFailure() async throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let viewModel = ClosetViewModel(classifier: FailingClothingClassifier(), backgroundRemover: StubBackgroundRemover(result: nil), modelContext: ModelContext(container))

        let result = await viewModel.processPhoto(makeSolidColorImage(), orientation: .up)

        #expect(result == nil)
        #expect(viewModel.errorMessage != nil)
    }

    @Test func saveItemPersistsWithColorimetryMatch() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let profile = UserColorimetryProfile(
            name: nil, skinToneSample: .beige, eyeColorSample: .wine, hairColorSample: .wine,
            season: .autumn,
            recommendedColors: SeasonPalette.recommendedColors(for: .autumn),
            avoidColors: SeasonPalette.avoidColors(for: .autumn)
        )
        context.insert(profile)
        try context.save()

        let classifier = FakeClothingClassifier(result: ClothingClassification(category: .tops, dominantColor: .lime))
        let viewModel = ClosetViewModel(classifier: classifier, modelContext: context)

        viewModel.saveItem(imageData: Data([0x01]), category: .tops, colorSwatch: .yellow)

        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.items.count == 1)
        #expect(viewModel.items.first?.category == .tops)
        #expect(viewModel.items.first?.matchesColorimetry == true)
    }

    @Test func saveItemWithoutProfileLeavesMatchesColorimetryNil() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let classifier = FakeClothingClassifier(result: ClothingClassification(category: .shoes, dominantColor: .deepBlack))
        let viewModel = ClosetViewModel(classifier: classifier, modelContext: context)

        viewModel.saveItem(imageData: Data([0x01]), category: .shoes, colorSwatch: .black)

        #expect(viewModel.items.first?.matchesColorimetry == nil)
    }

    @Test func loadItemsFetchesExistingItemsSortedByNewestFirst() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let older = ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: nil, dateAdded: .now.addingTimeInterval(-100))
        let newer = ClothingItem(imageData: Data(), category: .bottoms, dominantColor: .wine, matchesColorimetry: nil, dateAdded: .now)
        context.insert(older)
        context.insert(newer)
        try context.save()

        let classifier = FakeClothingClassifier(result: ClothingClassification(category: .tops, dominantColor: .lime))
        let viewModel = ClosetViewModel(classifier: classifier, modelContext: context)

        #expect(viewModel.items.map(\.category) == [.bottoms, .tops])
    }

    @Test func loadItemsPopulatesProfileNameWhenProfileExists() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let profile = UserColorimetryProfile(
            name: "Ana Carolina", skinToneSample: .beige, eyeColorSample: .wine, hairColorSample: .wine,
            season: .autumn,
            recommendedColors: SeasonPalette.recommendedColors(for: .autumn),
            avoidColors: SeasonPalette.avoidColors(for: .autumn)
        )
        context.insert(profile)
        try context.save()

        let classifier = FakeClothingClassifier(result: ClothingClassification(category: .tops, dominantColor: .lime))
        let viewModel = ClosetViewModel(classifier: classifier, modelContext: context)

        #expect(viewModel.profileName == "Ana Carolina")
    }

    @Test func profileNameIsNilWithoutProfile() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let classifier = FakeClothingClassifier(result: ClothingClassification(category: .tops, dominantColor: .lime))
        let viewModel = ClosetViewModel(classifier: classifier, modelContext: context)

        #expect(viewModel.profileName == nil)
    }
}
