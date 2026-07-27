import Foundation

enum SeasonPalette {
    static func recommendedColors(for season: Season) -> [ClosetColor] {
        switch season {
        case .warmSpring: return [.coral, .golden, .turquoise, .warmIvory, .brightAqua, .lime, .mustard, .peach]
        case .lightSpring: return [.peach, .warmIvory, .coral, .brightAqua, .golden, .turquoise, .lime, .camel]
        case .clearSpring: return [.turquoise, .trueRed, .brightAqua, .golden, .coral, .lime, .hotPink, .warmIvory]

        case .coolSummer: return [.softBlue, .dustyRose, .plum, .slate, .lavender, .roseGray, .icyBlue, .emerald]
        case .lightSummer: return [.powderBlue, .dustyRose, .lavender, .roseGray, .softBlue, .icyBlue, .mauve, .slate]
        case .softSummer: return [.roseGray, .sage, .slate, .lavender, .dustyRose, .plum, .powderBlue, .mauve]

        case .warmAutumn: return [.rust, .olive, .camel, .golden, .mustard, .forest, .sage, .warmIvory]
        case .softAutumn: return [.camel, .sage, .mauve, .beige, .olive, .dustyRose, .forest, .rust]
        case .deepAutumn: return [.rust, .forest, .wine, .mustard, .olive, .camel, .charcoal, .golden]

        case .coolWinter: return [.trueRed, .royalBlue, .emerald, .deepBlack, .charcoal, .plum, .slate, .icyBlue]
        case .clearWinter: return [.trueRed, .brightAqua, .hotPink, .deepBlack, .royalBlue, .emerald, .icyBlue, .charcoal]
        case .deepWinter: return [.wine, .forest, .royalBlue, .charcoal, .plum, .deepBlack, .slate, .emerald]
        }
    }

    /// Curated per subseason rather than mirrored from an "opposite" season: what
    /// washes out a Light Spring isn't what washes out a Clear Spring, even though
    /// both are springs.
    static func avoidColors(for season: Season) -> [ClosetColor] {
        switch season {
        case .warmSpring: return [.deepBlack, .slate, .icyBlue, .roseGray]
        case .lightSpring: return [.deepBlack, .wine, .charcoal, .slate]
        case .clearSpring: return [.beige, .roseGray, .mauve, .olive]

        case .coolSummer: return [.golden, .rust, .camel, .mustard]
        case .lightSummer: return [.deepBlack, .rust, .mustard, .wine]
        case .softSummer: return [.trueRed, .golden, .brightAqua, .rust]

        case .warmAutumn: return [.icyBlue, .powderBlue, .hotPink, .deepBlack]
        case .softAutumn: return [.trueRed, .brightAqua, .deepBlack, .hotPink]
        case .deepAutumn: return [.powderBlue, .peach, .icyBlue, .roseGray]

        case .coolWinter: return [.camel, .beige, .rust, .olive]
        case .clearWinter: return [.beige, .camel, .sage, .mauve]
        case .deepWinter: return [.peach, .beige, .camel, .golden]
        }
    }
}
