// AcademyAI/AcademyAITests/WardrobeAnalyzerTests.swift
import Foundation
import Testing
@testable import AcademyAI

struct WardrobeAnalyzerTests {
    // MARK: - categoryCounts

    @Test func categoryCountsIncludesAllCategoriesEvenAtZero() {
        let items = [
            ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: nil),
            ClothingItem(imageData: Data(), category: .tops, dominantColor: .wine, matchesColorimetry: nil)
        ]
        let counts = WardrobeAnalyzer.categoryCounts(items: items)
        #expect(counts == [
            .init(category: .tops, count: 2),
            .init(category: .bottoms, count: 0),
            .init(category: .outerwear, count: 0),
            .init(category: .shoes, count: 0),
            .init(category: .other, count: 0)
        ])
    }

    // MARK: - percentInPalette

    @Test func percentInPaletteIsNilWhenNoItemHasColorimetryScored() {
        let items = [ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: nil)]
        #expect(WardrobeAnalyzer.percentInPalette(items: items) == nil)
    }

    @Test func percentInPaletteIsNilWhenClosetIsEmpty() {
        #expect(WardrobeAnalyzer.percentInPalette(items: []) == nil)
    }

    @Test func percentInPaletteIgnoresItemsWithoutColorimetryScore() {
        let items = [
            ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: true),
            ClothingItem(imageData: Data(), category: .bottoms, dominantColor: .wine, matchesColorimetry: false),
            ClothingItem(imageData: Data(), category: .shoes, dominantColor: .beige, matchesColorimetry: nil)
        ]
        #expect(WardrobeAnalyzer.percentInPalette(items: items) == 0.5)
    }

    // MARK: - gapCategory

    @Test func gapCategoryIsNilWhenClosetIsEmpty() {
        #expect(WardrobeAnalyzer.gapCategory(items: []) == nil)
    }

    @Test func gapCategoryIsNilWhenLeadingCategoryHasFewerThanTwoItems() {
        let items = [ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: nil)]
        #expect(WardrobeAnalyzer.gapCategory(items: items) == nil)
    }

    @Test func gapCategoryIsNilWhenAllEligibleCategoriesAreBalanced() {
        let items = ClothingCategory.allCases
            .filter { $0 != .other }
            .flatMap { category in
                [
                    ClothingItem(imageData: Data(), category: category, dominantColor: .lime, matchesColorimetry: nil),
                    ClothingItem(imageData: Data(), category: category, dominantColor: .wine, matchesColorimetry: nil)
                ]
            }
        #expect(WardrobeAnalyzer.gapCategory(items: items) == nil)
    }

    @Test func gapCategoryReturnsMostUnderRepresentedEligibleCategory() {
        let items =
            Array(repeating: ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: nil), count: 3) +
            Array(repeating: ClothingItem(imageData: Data(), category: .outerwear, dominantColor: .lime, matchesColorimetry: nil), count: 3) +
            [ClothingItem(imageData: Data(), category: .shoes, dominantColor: .lime, matchesColorimetry: nil)]
        #expect(WardrobeAnalyzer.gapCategory(items: items) == .bottoms)
    }

    @Test func gapCategoryIgnoresOtherCategoryEntirely() {
        let items =
            Array(repeating: ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: nil), count: 3) +
            Array(repeating: ClothingItem(imageData: Data(), category: .other, dominantColor: .lime, matchesColorimetry: nil), count: 5)
        #expect(WardrobeAnalyzer.gapCategory(items: items) == .bottoms)
    }

    // MARK: - suggestedSwatches

    @Test func suggestedSwatchesIsEmptyWithNoRecommendedColors() {
        #expect(WardrobeAnalyzer.suggestedSwatches(recommendedColors: []).isEmpty)
    }

    @Test func suggestedSwatchesDedupesToNearestNamedSwatch() {
        // .lime and a near-identical RGB both resolve to the same nearest swatch.
        let nearlyLime = ClosetColor(red: 0.82, green: 0.82, blue: 0.43)
        let swatches = WardrobeAnalyzer.suggestedSwatches(recommendedColors: [.lime, nearlyLime, .wine])
        #expect(swatches == [ClothingColorSwatch.nearest(to: .lime), ClothingColorSwatch.nearest(to: .wine)])
    }

    @Test func suggestedSwatchesRespectsLimit() {
        let colors: [ClosetColor] = [.lime, .wine, .beige, .mauve]
        #expect(WardrobeAnalyzer.suggestedSwatches(recommendedColors: colors, limit: 2).count == 2)
    }
}
