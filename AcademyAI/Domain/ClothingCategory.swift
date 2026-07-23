import Foundation

enum ClothingCategory: String, Codable, CaseIterable {
    case tops, bottoms, outerwear, shoes, other

    /// Singular noun for item titles ("Teal " + displayNoun -> "Teal Top").
    var displayNoun: String {
        switch self {
        case .tops: return "Top"
        case .bottoms: return "Bottoms"
        case .outerwear: return "Jacket"
        case .shoes: return "Shoes"
        case .other: return "Piece"
        }
    }

    /// Plural, lowercase — for "N similar {pluralDisplayName} already in your closet".
    var pluralDisplayName: String {
        switch self {
        case .tops: return "tops"
        case .bottoms: return "bottoms"
        case .outerwear: return "jackets"
        case .shoes: return "shoes"
        case .other: return "pieces"
        }
    }
}
