// AcademyAI/AcademyAITests/ProfileViewModelTests.swift
import Foundation
import Testing
import SwiftData
@testable import AcademyAI

@MainActor
struct ProfileViewModelTests {
    @Test func loadProfileReadsNameSeasonAllSwatchesAndExplanation() throws {
        let container = try ModelContainer(for: UserColorimetryProfile.self, ClothingItem.self, PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let profile = UserColorimetryProfile(
            name: "Ana Carolina", skinToneSample: .beige, eyeColorSample: .wine, hairColorSample: .wine,
            season: .warmAutumn, recommendedColors: SeasonPalette.recommendedColors(for: .warmAutumn), avoidColors: [],
            explanationText: "Warm Autumn reads rich and earthy."
        )
        context.insert(profile)
        try context.save()

        let viewModel = ProfileViewModel(modelContext: context)

        #expect(viewModel.profileName == "Ana Carolina")
        #expect(viewModel.season == .warmAutumn)
        #expect(viewModel.paletteSwatches == SeasonPalette.recommendedColors(for: .warmAutumn))
        #expect(viewModel.explanation == "Warm Autumn reads rich and earthy.")
    }

    @Test func checkedCountAndClosetCountReflectStoredRecords() throws {
        let container = try ModelContainer(for: UserColorimetryProfile.self, ClothingItem.self, PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        context.insert(ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: nil))
        context.insert(ClothingItem(imageData: Data(), category: .bottoms, dominantColor: .wine, matchesColorimetry: nil))
        context.insert(PurchaseCheck(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: nil, fillsGap: nil, verdictText: "x", decision: .comprou))
        try context.save()

        let viewModel = ProfileViewModel(modelContext: context)

        #expect(viewModel.checkedCount == 1)
        #expect(viewModel.closetCount == 2)
    }

    @Test func profileInitialsUsesFirstLetterOfFirstTwoNameWords() throws {
        let container = try ModelContainer(for: UserColorimetryProfile.self, ClothingItem.self, PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        context.insert(UserColorimetryProfile(
            name: "Ana Carolina", skinToneSample: .beige, eyeColorSample: .wine, hairColorSample: .wine,
            season: .warmAutumn, recommendedColors: [], avoidColors: []
        ))
        try context.save()

        let viewModel = ProfileViewModel(modelContext: context)

        #expect(viewModel.profileInitials == "AC")
    }

    @Test func profileInitialsIsQuestionMarkWithoutProfile() throws {
        let container = try ModelContainer(for: UserColorimetryProfile.self, ClothingItem.self, PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let viewModel = ProfileViewModel(modelContext: ModelContext(container))

        #expect(viewModel.profileInitials == "?")
    }

    @Test func loadProfileRefreshesAfterExternalUpdate() throws {
        let container = try ModelContainer(for: UserColorimetryProfile.self, ClothingItem.self, PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let viewModel = ProfileViewModel(modelContext: context)
        #expect(viewModel.profileName == nil)

        context.insert(UserColorimetryProfile(
            name: "Ana", skinToneSample: .beige, eyeColorSample: .wine, hairColorSample: .wine,
            season: .coolWinter, recommendedColors: [], avoidColors: []
        ))
        try context.save()
        viewModel.loadProfile()

        #expect(viewModel.profileName == "Ana")
    }
}
