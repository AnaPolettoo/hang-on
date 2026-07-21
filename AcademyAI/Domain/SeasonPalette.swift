import Foundation

enum SeasonPalette {
    static func recommendedColors(for season: Season) -> [ClothingColor] {
        switch season {
        case .spring: return [.coral, .peach, .turquoise, .golden]
        case .summer: return [.softBlue, .lavender, .roseGray, .slate]
        case .autumn: return [.lime, .wine, .beige, .mauve]
        case .winter: return [.icyBlue, .emerald, .trueRed, .deepBlack]
        }
    }

    static func avoidColors(for season: Season) -> [ClothingColor] {
        recommendedColors(for: season.opposite)
    }
}
