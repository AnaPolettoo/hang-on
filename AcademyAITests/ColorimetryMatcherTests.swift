import Testing
@testable import AcademyAI

struct ColorimetryMatcherTests {
    @Test func returnsNilWhenNoProfile() {
        #expect(ColorimetryMatcher.matches(color: .lime, profile: nil) == nil)
    }

    @Test func returnsTrueWhenColorIsCloserToRecommended() {
        let profile = UserColorimetryProfile(
            name: nil,
            skinToneSample: .beige, eyeColorSample: .wine, hairColorSample: .wine,
            season: .autumn,
            recommendedColors: SeasonPalette.recommendedColors(for: .autumn),
            avoidColors: SeasonPalette.avoidColors(for: .autumn)
        )
        #expect(ColorimetryMatcher.matches(color: .lime, profile: profile) == true)
    }

    @Test func returnsFalseWhenColorIsCloserToAvoid() {
        let profile = UserColorimetryProfile(
            name: nil,
            skinToneSample: .beige, eyeColorSample: .wine, hairColorSample: .wine,
            season: .autumn,
            recommendedColors: SeasonPalette.recommendedColors(for: .autumn),
            avoidColors: SeasonPalette.avoidColors(for: .autumn)
        )
        #expect(ColorimetryMatcher.matches(color: .icyBlue, profile: profile) == false)
    }
}
