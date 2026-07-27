import Foundation

enum SeasonPalette {
    static func recommendedColors(for season: Season) -> [ClosetColor] {
        switch season {
        case .warmSpring: return [.coral, .golden, .turquoise, .warmIvory]
        case .lightSpring: return [.peach, .warmIvory, .coral, .brightAqua]
        case .clearSpring: return [.turquoise, .trueRed, .brightAqua, .golden]

        case .coolSummer: return [.softBlue, .dustyRose, .plum, .slate]
        case .lightSummer: return [.powderBlue, .dustyRose, .lavender, .roseGray]
        case .softSummer: return [.roseGray, .sage, .slate, .lavender]

        case .warmAutumn: return [.rust, .olive, .camel, .golden]
        case .softAutumn: return [.camel, .sage, .mauve, .beige]
        case .deepAutumn: return [.rust, .forest, .wine, .mustard]

        case .coolWinter: return [.trueRed, .royalBlue, .emerald, .deepBlack]
        case .clearWinter: return [.trueRed, .brightAqua, .hotPink, .deepBlack]
        case .deepWinter: return [.wine, .forest, .royalBlue, .charcoal]
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
