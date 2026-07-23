import Foundation
import Testing
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
}
