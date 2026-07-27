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
            season: .warmAutumn,
            recommendedColors: SeasonPalette.recommendedColors(for: .warmAutumn),
            avoidColors: SeasonPalette.avoidColors(for: .warmAutumn)
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

    @Test func saveItemPersistsPatternFlag() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let viewModel = ClosetViewModel(modelContext: context)

        viewModel.saveItem(
            imageData: Data([0x01]), category: .tops, colorSwatch: .yellow, isPatterned: true
        )

        let saved = try context.fetch(FetchDescriptor<ClothingItem>())
        #expect(saved.count == 1)
        #expect(saved.first?.isPatterned == true)
    }

    @Test func saveItemDefaultsToNotPatterned() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let viewModel = ClosetViewModel(modelContext: context)

        viewModel.saveItem(imageData: Data([0x01]), category: .tops, colorSwatch: .yellow)

        let saved = try context.fetch(FetchDescriptor<ClothingItem>())
        #expect(saved.first?.isPatterned == false)
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

    @Test func deleteItemRemovesItFromStoreAndList() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let viewModel = ClosetViewModel(modelContext: context)
        viewModel.saveItem(imageData: Data([0x01]), category: .tops, colorSwatch: .yellow)
        let item = try #require(viewModel.items.first)

        viewModel.deleteItem(item)

        #expect(viewModel.items.isEmpty)
        #expect(try context.fetch(FetchDescriptor<ClothingItem>()).isEmpty)
    }

    @Test func deleteItemLeavesOtherItemsUntouched() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let viewModel = ClosetViewModel(modelContext: context)
        viewModel.saveItem(imageData: Data([0x01]), category: .tops, colorSwatch: .yellow)
        viewModel.saveItem(imageData: Data([0x02]), category: .bottoms, colorSwatch: .navy)
        let toDelete = try #require(viewModel.items.first { $0.category == .tops })

        viewModel.deleteItem(toDelete)

        #expect(viewModel.items.count == 1)
        #expect(viewModel.items.first?.category == .bottoms)
    }

    @Test func deleteItemLeavesLinkedPurchaseCheckIntact() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let check = PurchaseCheck(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: true, fillsGap: nil, verdictText: "x", decision: .comprou)
        context.insert(check)
        let item = ClothingItem(
            imageData: Data([0x01]), category: .tops, dominantColor: .lime, matchesColorimetry: true,
            acquiredViaPurchaseCheck: true, linkedPurchaseCheckId: check.id
        )
        context.insert(item)
        try context.save()
        let viewModel = ClosetViewModel(modelContext: context)

        viewModel.deleteItem(item)

        #expect(try context.fetch(FetchDescriptor<PurchaseCheck>()).count == 1)
        #expect(viewModel.items.isEmpty)
    }

    @Test func deleteItemRecalculatesPercentInPalette() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let viewModel = ClosetViewModel(modelContext: context)
        viewModel.saveItem(imageData: Data([0x01]), category: .tops, colorSwatch: .yellow) // no profile -> matchesColorimetry nil
        let offPaletteItem = ClothingItem(imageData: Data([0x02]), category: .bottoms, dominantColor: .royalBlue, matchesColorimetry: false)
        let onPaletteItem = ClothingItem(imageData: Data([0x03]), category: .shoes, dominantColor: .lime, matchesColorimetry: true)
        context.insert(offPaletteItem)
        context.insert(onPaletteItem)
        try context.save()
        viewModel.loadItems()
        #expect(WardrobeAnalyzer.percentInPalette(items: viewModel.items) == 0.5)

        viewModel.deleteItem(offPaletteItem)

        #expect(WardrobeAnalyzer.percentInPalette(items: viewModel.items) == 1.0)
    }

    @Test func deleteItemClearsPriorErrorMessageOnSuccess() async throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let viewModel = ClosetViewModel(classifier: FailingClothingClassifier(), modelContext: context)
        viewModel.saveItem(imageData: Data([0x01]), category: .tops, colorSwatch: .yellow)
        let item = try #require(viewModel.items.first)
        _ = await viewModel.processPhoto(makeSolidColorImage(), orientation: .up) // leaves errorMessage != nil
        #expect(viewModel.errorMessage != nil)

        viewModel.deleteItem(item)

        #expect(viewModel.errorMessage == nil)
    }
}
