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
            season: .warmAutumn,
            recommendedColors: SeasonPalette.recommendedColors(for: .warmAutumn),
            avoidColors: SeasonPalette.avoidColors(for: .warmAutumn)
        )
        #expect(ColorimetryMatcher.matches(color: .lime, profile: profile) == true)
    }

    @Test func returnsFalseWhenColorIsCloserToAvoid() {
        let profile = UserColorimetryProfile(
            name: nil,
            skinToneSample: .beige, eyeColorSample: .wine, hairColorSample: .wine,
            season: .warmAutumn,
            recommendedColors: SeasonPalette.recommendedColors(for: .warmAutumn),
            avoidColors: SeasonPalette.avoidColors(for: .warmAutumn)
        )
        // A clear medium blue: squared-distance to avoid's .slate (~0.0425) is far
        // below the distance to recommended's nearest color, .mauve (~0.263) — not
        // ambiguous the way `.icyBlue` is (which sits closer to `.beige`, a light
        // neutral, than to any autumn avoid color).
        let coolBlue = ClosetColor(red: 0.35, green: 0.45, blue: 0.75)
        #expect(ColorimetryMatcher.matches(color: coolBlue, profile: profile) == false)
    }
}
