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
        // A light, pastel cool blue: squared-distance to avoid's .powderBlue (~0.015)
        // is far below the distance to recommended's nearest color, .sage (~0.142) —
        // not ambiguous the way a *dark* blue would be (RGB distance conflates
        // darkness with hue, so a navy reads deceptively close to dark recommended
        // colors like .forest purely because both are dark).
        let coolBlue = ClosetColor(red: 0.60, green: 0.75, blue: 0.92)
        #expect(ColorimetryMatcher.matches(color: coolBlue, profile: profile) == false)
    }
}
