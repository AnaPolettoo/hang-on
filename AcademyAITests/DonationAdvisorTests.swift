import Foundation
import Testing
import SwiftData
@testable import AcademyAI

struct DonationAdvisorTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: now)!
    }

    @Test func singleCriterionAloneIsNotACandidate() {
        // Off-palette only: recently worn, no duplicates.
        let item = ClothingItem(imageData: Data(), category: .tops, dominantColor: ClothingColorSwatch.teal.color, matchesColorimetry: false)
        item.lastWornDate = daysAgo(5)

        let result = DonationAdvisor.candidates(items: [item], now: now)

        #expect(result.isEmpty)
    }

    @Test func twoCriteriaMakeACandidateAndReportWhichOnes() throws {
        // Forgotten + off-palette, no duplicates (only item of its kind).
        let item = ClothingItem(imageData: Data(), category: .tops, dominantColor: ClothingColorSwatch.teal.color, matchesColorimetry: false)
        item.lastWornDate = daysAgo(120)

        let result = DonationAdvisor.candidates(items: [item], now: now)

        let candidate = try #require(result.first)
        #expect(candidate.isForgotten == true)
        #expect(candidate.isOffPalette == true)
        #expect(candidate.isDuplicate == false)
        #expect(candidate.daysSinceWorn == 120)
    }

    @Test func neverLoggedOffPaletteDuplicateIsNotACandidate() {
        // REQ-F.1.1: target is off-palette and has 3 same-category/color siblings
        // (so it WOULD be a duplicate), but was never logged — must not qualify.
        let target = ClothingItem(imageData: Data(), category: .tops, dominantColor: ClothingColorSwatch.teal.color, matchesColorimetry: false)
        let sibling1 = ClothingItem(imageData: Data(), category: .tops, dominantColor: ClothingColorSwatch.teal.color, matchesColorimetry: false)
        sibling1.lastWornDate = daysAgo(10)
        let sibling2 = ClothingItem(imageData: Data(), category: .tops, dominantColor: ClothingColorSwatch.teal.color, matchesColorimetry: false)
        sibling2.lastWornDate = daysAgo(10)
        let sibling3 = ClothingItem(imageData: Data(), category: .tops, dominantColor: ClothingColorSwatch.teal.color, matchesColorimetry: false)
        sibling3.lastWornDate = daysAgo(10)

        let result = DonationAdvisor.candidates(items: [target, sibling1, sibling2, sibling3], now: now, duplicateThreshold: 3)

        #expect(!result.contains { $0.item.persistentModelID == target.persistentModelID })
    }

    @Test func noItemsLoggedAtAllProducesNoCandidates() {
        // REQ-F.7: whole closet has zero wear logs, even though these four
        // would otherwise satisfy off-palette + duplicate.
        let a = ClothingItem(imageData: Data(), category: .tops, dominantColor: ClothingColorSwatch.teal.color, matchesColorimetry: false)
        let b = ClothingItem(imageData: Data(), category: .tops, dominantColor: ClothingColorSwatch.teal.color, matchesColorimetry: false)
        let c = ClothingItem(imageData: Data(), category: .tops, dominantColor: ClothingColorSwatch.teal.color, matchesColorimetry: false)
        let d = ClothingItem(imageData: Data(), category: .tops, dominantColor: ClothingColorSwatch.teal.color, matchesColorimetry: false)

        let result = DonationAdvisor.candidates(items: [a, b, c, d], now: now, duplicateThreshold: 3)

        #expect(result.isEmpty)
    }

    @Test func neutralOffPaletteItemDoesNotCountTowardOffPaletteCriterion() {
        // Forgotten only (black is neutral, so off-palette criterion doesn't fire
        // even though matchesColorimetry == false) — total of 1, not a candidate.
        let item = ClothingItem(imageData: Data(), category: .tops, dominantColor: ClothingColorSwatch.black.color, matchesColorimetry: false)
        item.lastWornDate = daysAgo(120)

        let result = DonationAdvisor.candidates(items: [item], now: now)

        #expect(result.isEmpty)
    }

    @Test func sameClosetAndDateProduceSameResult() {
        let item = ClothingItem(imageData: Data(), category: .tops, dominantColor: ClothingColorSwatch.teal.color, matchesColorimetry: false)
        item.lastWornDate = daysAgo(120)

        let result1 = DonationAdvisor.candidates(items: [item], now: now)
        let result2 = DonationAdvisor.candidates(items: [item], now: now)

        #expect(result1.count == result2.count)
        #expect(result1.first?.isForgotten == result2.first?.isForgotten)
        #expect(result1.first?.isOffPalette == result2.first?.isOffPalette)
    }
}
