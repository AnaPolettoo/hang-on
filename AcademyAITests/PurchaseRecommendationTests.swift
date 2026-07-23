import Testing
@testable import AcademyAI

struct PurchaseRecommendationTests {
    @Test func offPaletteIsSkipItRegardlessOfGap() {
        #expect(PurchaseRecommendation.evaluate(matchesColorimetry: false, fillsGap: true) == .skipIt)
        #expect(PurchaseRecommendation.evaluate(matchesColorimetry: false, fillsGap: false) == .skipIt)
        #expect(PurchaseRecommendation.evaluate(matchesColorimetry: false, fillsGap: nil) == .skipIt)
    }

    @Test func onPaletteButDuplicateIsAlreadyOwned() {
        #expect(PurchaseRecommendation.evaluate(matchesColorimetry: true, fillsGap: false) == .alreadyOwned)
    }

    @Test func duplicateWithUnknownPaletteIsAlreadyOwned() {
        #expect(PurchaseRecommendation.evaluate(matchesColorimetry: nil, fillsGap: false) == .alreadyOwned)
    }

    @Test func onPaletteAndFillsGapIsWorthIt() {
        #expect(PurchaseRecommendation.evaluate(matchesColorimetry: true, fillsGap: true) == .worthIt)
    }

    @Test func allUnknownDefaultsToWorthIt() {
        #expect(PurchaseRecommendation.evaluate(matchesColorimetry: nil, fillsGap: nil) == .worthIt)
    }

    @Test func unknownPaletteWithGapIsWorthIt() {
        #expect(PurchaseRecommendation.evaluate(matchesColorimetry: nil, fillsGap: true) == .worthIt)
    }
}
