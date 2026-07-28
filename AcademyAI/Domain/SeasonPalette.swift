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

    /// Display name for a recommended-palette color, e.g. for the palette result
    /// screen and the "why these colors" explanation screen. `default: "Color"`
    /// only fires for a `ClosetColor` outside the 30 named cases in
    /// `Domain/ClosetColor.swift` — every color actually used by
    /// `recommendedColors(for:)` above is covered by name.
    static func displayName(for color: ClosetColor) -> String {
        switch color {
        case .lime: return "Lime, everyday base"
        case .wine: return "Wine, rich accent"
        case .beige: return "Beige, neutral"
        case .mauve: return "Mauve, pop of color"
        case .coral: return "Coral"
        case .peach: return "Peach"
        case .turquoise: return "Turquoise"
        case .golden: return "Golden"
        case .softBlue: return "Soft Blue"
        case .lavender: return "Lavender"
        case .roseGray: return "Rose Gray"
        case .slate: return "Slate"
        case .icyBlue: return "Icy Blue"
        case .emerald: return "Emerald"
        case .trueRed: return "True Red"
        case .deepBlack: return "Black"
        case .warmIvory: return "Warm Ivory"
        case .brightAqua: return "Bright Aqua"
        case .rust: return "Rust"
        case .olive: return "Olive"
        case .camel: return "Camel"
        case .sage: return "Sage"
        case .mustard: return "Mustard"
        case .forest: return "Forest"
        case .dustyRose: return "Dusty Rose"
        case .plum: return "Plum"
        case .powderBlue: return "Powder Blue"
        case .royalBlue: return "Royal Blue"
        case .charcoal: return "Charcoal"
        case .hotPink: return "Hot Pink"
        default: return "Color"
        }
    }
}
