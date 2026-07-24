import Foundation
import Testing
import SwiftData
@testable import AcademyAI

@MainActor
struct AnalysisViewModelTests {
    @Test func totalCountReflectsLoadedItems() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        context.insert(ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: nil))
        context.insert(ClothingItem(imageData: Data(), category: .bottoms, dominantColor: .wine, matchesColorimetry: nil))
        try context.save()

        let viewModel = AnalysisViewModel(modelContext: context)

        #expect(viewModel.totalCount == 2)
    }

    @Test func totalCountIsZeroWithEmptyCloset() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let viewModel = AnalysisViewModel(modelContext: ModelContext(container))

        #expect(viewModel.totalCount == 0)
        #expect(viewModel.percentInPalette == nil)
        #expect(viewModel.gapCategory == nil)
        #expect(viewModel.suggestedSwatches.isEmpty)
        #expect(viewModel.offPaletteItems.isEmpty)
    }

    @Test func categoryCountsMatchesLoadedItems() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        context.insert(ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: nil))
        try context.save()

        let viewModel = AnalysisViewModel(modelContext: context)

        #expect(viewModel.categoryCounts.first { $0.category == .tops }?.count == 1)
    }

    @Test func offPaletteItemsOnlyIncludesFalseMatches() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let offPalette = ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: false)
        context.insert(offPalette)
        context.insert(ClothingItem(imageData: Data(), category: .bottoms, dominantColor: .wine, matchesColorimetry: true))
        context.insert(ClothingItem(imageData: Data(), category: .shoes, dominantColor: .beige, matchesColorimetry: nil))
        try context.save()

        let viewModel = AnalysisViewModel(modelContext: context)

        #expect(viewModel.offPaletteItems.map(\.persistentModelID) == [offPalette.persistentModelID])
    }

    @Test func suggestedSwatchesEmptyWithoutProfileEvenWithGap() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        for _ in 0..<3 {
            context.insert(ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: nil))
        }
        try context.save()

        let viewModel = AnalysisViewModel(modelContext: context)

        #expect(viewModel.gapCategory != nil)
        #expect(viewModel.suggestedSwatches.isEmpty)
    }

    @Test func suggestedSwatchesUsesProfileRecommendedColorsWhenGapExists() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        for _ in 0..<3 {
            context.insert(ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: nil))
        }
        let profile = UserColorimetryProfile(
            name: nil, skinToneSample: .beige, eyeColorSample: .wine, hairColorSample: .wine,
            season: .autumn, recommendedColors: [.lime, .wine], avoidColors: []
        )
        context.insert(profile)
        try context.save()

        let viewModel = AnalysisViewModel(modelContext: context)

        #expect(viewModel.suggestedSwatches == WardrobeAnalyzer.suggestedSwatches(recommendedColors: [.lime, .wine]))
    }

    @Test func loadItemsRefreshesAfterExternalInsert() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let viewModel = AnalysisViewModel(modelContext: context)
        #expect(viewModel.totalCount == 0)

        context.insert(ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: nil))
        try context.save()
        viewModel.loadItems()

        #expect(viewModel.totalCount == 1)
    }
}
