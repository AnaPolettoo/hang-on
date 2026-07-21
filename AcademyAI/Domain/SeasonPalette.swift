import Foundation

enum SeasonPalette {
    static func recommendedColors(for season: Season) -> [ClosetColor] {
        switch season {
        case .spring: return [.coral, .peach, .turquoise, .golden]
        case .summer: return [.softBlue, .lavender, .roseGray, .slate]
        case .autumn: return [.lime, .wine, .beige, .mauve]
        case .winter: return [.icyBlue, .emerald, .trueRed, .deepBlack]
        }
    }

    static func avoidColors(for season: Season) -> [ClosetColor] {
        recommendedColors(for: season.opposite)
    }
}
