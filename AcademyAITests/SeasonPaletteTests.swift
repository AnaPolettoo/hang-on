import Testing
@testable import AcademyAI

struct SeasonPaletteTests {
    @Test func everySeasonHasEightRecommendedColors() {
        for season in Season.allCases {
            #expect(SeasonPalette.recommendedColors(for: season).count == 8)
        }
    }

    @Test func everySeasonHasFourAvoidColors() {
        for season in Season.allCases {
            #expect(SeasonPalette.avoidColors(for: season).count == 4)
        }
    }

    @Test func recommendedAndAvoidNeverOverlap() {
        for season in Season.allCases {
            let recommended = Set(SeasonPalette.recommendedColors(for: season).map(\.key))
            let avoid = Set(SeasonPalette.avoidColors(for: season).map(\.key))
            #expect(recommended.isDisjoint(with: avoid))
        }
    }

    @Test func everySeasonHasItsOwnRecommendedPalette() {
        let palettes = Season.allCases.map { season in
            Set(SeasonPalette.recommendedColors(for: season).map(\.key))
        }
        #expect(Set(palettes).count == Season.allCases.count)
    }

    @Test func warmAutumnPaletteMatchesProductPersona() {
        let palette = SeasonPalette.recommendedColors(for: .warmAutumn)
        #expect(palette.contains(ClosetColor.rust))
        #expect(palette.contains(ClosetColor.olive))
        #expect(palette.contains(ClosetColor.camel))
        #expect(palette.contains(ClosetColor.golden))
    }

    @Test func everyRecommendedColorAcrossEverySeasonHasADisplayName() {
        for season in Season.allCases {
            for color in SeasonPalette.recommendedColors(for: season) {
                #expect(SeasonPalette.displayName(for: color) != "Color", "missing display name for a color used by \(season)")
            }
        }
    }
}

private extension ClosetColor {
    var key: String { "\(red)-\(green)-\(blue)" }
}
