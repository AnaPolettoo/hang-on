import Foundation
import Testing
import SwiftData
@testable import AcademyAI

struct GapAnalyzerTests {
    @Test func returnsNilWhenClosetIsEmpty() {
        #expect(GapAnalyzer.fillsGap(candidateCategory: .tops, candidateColor: .lime, existingItems: []) == nil)
    }

    @Test func returnsTrueWhenNoExistingItemSharesCategoryAndColor() {
        let existing = ClothingItem(imageData: Data(), category: .bottoms, dominantColor: ClothingColorSwatch.navy.color, matchesColorimetry: nil)
        #expect(GapAnalyzer.fillsGap(candidateCategory: .tops, candidateColor: ClothingColorSwatch.red.color, existingItems: [existing]) == true)
    }

    @Test func returnsFalseWhenCategoryAndNearestColorAlreadyExist() {
        let existing = ClothingItem(imageData: Data(), category: .tops, dominantColor: ClothingColorSwatch.red.color, matchesColorimetry: nil)
        #expect(GapAnalyzer.fillsGap(candidateCategory: .tops, candidateColor: ClothingColorSwatch.red.color, existingItems: [existing]) == false)
    }

    @Test func returnsTrueWhenSameCategoryButDifferentColor() {
        let existing = ClothingItem(imageData: Data(), category: .tops, dominantColor: ClothingColorSwatch.navy.color, matchesColorimetry: nil)
        #expect(GapAnalyzer.fillsGap(candidateCategory: .tops, candidateColor: ClothingColorSwatch.red.color, existingItems: [existing]) == true)
    }

    @Test func returnsTrueWhenSameColorButDifferentCategory() {
        let existing = ClothingItem(imageData: Data(), category: .bottoms, dominantColor: ClothingColorSwatch.red.color, matchesColorimetry: nil)
        #expect(GapAnalyzer.fillsGap(candidateCategory: .tops, candidateColor: ClothingColorSwatch.red.color, existingItems: [existing]) == true)
    }

    @Test func similarItemsReturnsEmptyWhenClosetIsEmpty() {
        #expect(GapAnalyzer.similarItems(candidateCategory: .tops, candidateColor: .lime, existingItems: []).isEmpty)
    }

    @Test func similarItemsMatchesSameCategoryAndNearestColor() {
        let matching = ClothingItem(imageData: Data(), category: .tops, dominantColor: ClothingColorSwatch.red.color, matchesColorimetry: nil)
        let differentCategory = ClothingItem(imageData: Data(), category: .bottoms, dominantColor: ClothingColorSwatch.red.color, matchesColorimetry: nil)
        let differentColor = ClothingItem(imageData: Data(), category: .tops, dominantColor: ClothingColorSwatch.navy.color, matchesColorimetry: nil)
        let result = GapAnalyzer.similarItems(candidateCategory: .tops, candidateColor: ClothingColorSwatch.red.color, existingItems: [matching, differentCategory, differentColor])
        #expect(result.map(\.persistentModelID) == [matching.persistentModelID])
    }
}
