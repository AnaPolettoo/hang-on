import Testing
@testable import AcademyAI

struct ClothingColorSwatchTests {
    @Test func nearestMatchesExactSwatch() {
        #expect(ClothingColorSwatch.nearest(to: ClothingColorSwatch.navy.color) == .navy)
    }

    @Test func nearestMatchesClosestSwatchForAnAmbiguousColor() {
        // Warm brownish-tan, clearly closer to taupe (0.620, 0.557, 0.486) than
        // to grey (0.604, 0.604, 0.604) — grey has no warmth in the red channel.
        let warmTan = ClosetColor(red: 0.65, green: 0.55, blue: 0.45)
        #expect(ClothingColorSwatch.nearest(to: warmTan) == .taupe)
    }

    @Test func allSwatchesHaveNonEmptyDisplayNames() {
        for swatch in ClothingColorSwatch.allCases {
            #expect(!swatch.displayName.isEmpty)
        }
    }

    @Test func allTwelveSwatchesArePresent() {
        #expect(ClothingColorSwatch.allCases.count == 12)
    }
}
