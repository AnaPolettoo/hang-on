import Testing
@testable import AcademyAI

struct SeasonPaletteTests {
    @Test func everySeasonHasFourRecommendedColors() {
        for season in Season.allCases {
            #expect(SeasonPalette.recommendedColors(for: season).count == 4)
        }
    }

    @Test func avoidColorsMatchOppositeSeasonRecommended() {
        for season in Season.allCases {
            let avoid = SeasonPalette.avoidColors(for: season)
            let oppositeRecommended = SeasonPalette.recommendedColors(for: season.opposite)
            #expect(avoid == oppositeRecommended)
        }
    }

    @Test func autumnPaletteMatchesProductPersona() {
        let autumn = SeasonPalette.recommendedColors(for: .autumn)
        #expect(autumn.contains(ClosetColor.lime))
        #expect(autumn.contains(ClosetColor.wine))
        #expect(autumn.contains(ClosetColor.beige))
        #expect(autumn.contains(ClosetColor.mauve))
    }
}
