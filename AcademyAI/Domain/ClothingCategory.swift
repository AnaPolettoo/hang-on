import Foundation

enum ClothingCategory: String, Codable, CaseIterable {
    case tops, bottoms, outerwear, dresses, shoes, other

    /// Singular noun for item titles ("Teal " + displayNoun -> "Teal Top").
    var displayNoun: String {
        switch self {
        case .tops: return String(localized: "Top")
        case .bottoms: return String(localized: "Bottoms")
        case .outerwear: return String(localized: "Jacket")
        case .dresses: return String(localized: "Dress")
        case .shoes: return String(localized: "Shoes")
        case .other: return String(localized: "Piece")
        }
    }

    /// Plural, lowercase — for "N similar {pluralDisplayName} already in your closet".
    var pluralDisplayName: String {
        switch self {
        case .tops: return String(localized: "tops")
        case .bottoms: return String(localized: "bottoms")
        case .outerwear: return String(localized: "jackets")
        case .dresses: return String(localized: "dresses")
        case .shoes: return String(localized: "shoes")
        case .other: return String(localized: "pieces")
        }
    }
}
