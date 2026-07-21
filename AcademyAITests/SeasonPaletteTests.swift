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
        #expect(autumn.contains(ClothingColor.lime))
        #expect(autumn.contains(ClothingColor.wine))
        #expect(autumn.contains(ClothingColor.beige))
        #expect(autumn.contains(ClothingColor.mauve))
    }
}
