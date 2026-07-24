import Foundation

enum ClothingCategoryMapper {
    // Ordered (not a Dictionary) so matching stays deterministic: for a given
    // identifiers list, the same category always wins, regardless of Swift's
    // unordered Dictionary iteration.
    private static let keywordsByCategory: [(ClothingCategory, [String])] = [
        (.tops, ["shirt", "jersey", "sweater", "sweatshirt", "cardigan", "blouse", "hoodie", "top"]),
        (.dresses, ["dress", "gown", "sundress"]),
        (.bottoms, ["jean", "trouser", "pant", "skirt", "short", "legging"]),
        (.outerwear, ["coat", "jacket", "blazer", "parka", "windbreaker", "vest"]),
        (.shoes, ["sneaker", "shoe", "boot", "sandal", "heel", "loafer", "slipper"])
    ]

    static func category(forIdentifiers identifiers: [String]) -> ClothingCategory {
        for identifier in identifiers {
            let normalized = identifier.lowercased()
            for (category, keywords) in keywordsByCategory {
                if keywords.contains(where: { normalized.contains($0) }) {
                    return category
                }
            }
        }
        return .other
    }
}
