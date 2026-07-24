import Foundation

enum WardrobeAnalyzer {
    struct CategoryCount: Equatable {
        let category: ClothingCategory
        let count: Int
    }

    /// Categories eligible for gap detection — `.other` is a catch-all, not a
    /// real wardrobe slot, so it never counts toward the imbalance check or
    /// shows up as the suggested gap (REQ-4.3).
    private static let gapEligibleCategories: [ClothingCategory] = [.tops, .bottoms, .outerwear, .shoes]

    static func categoryCounts(items: [ClothingItem]) -> [CategoryCount] {
        ClothingCategory.allCases.map { category in
            CategoryCount(category: category, count: items.filter { $0.category == category }.count)
        }
    }

    /// `nil` when no item has `matchesColorimetry` scored yet (colorimetry not
    /// done, or closet empty — REQ-4.1), otherwise the fraction of scored items
    /// that match the palette.
    static func percentInPalette(items: [ClothingItem]) -> Double? {
        let scored = items.filter { $0.matchesColorimetry != nil }
        guard !scored.isEmpty else { return nil }
        let matching = scored.filter { $0.matchesColorimetry == true }.count
        return Double(matching) / Double(scored.count)
    }

    /// The most under-represented category among `gapEligibleCategories`, or
    /// `nil` when there isn't enough data to call it a real imbalance (REQ-4.3
    /// / acceptance criterion: "só aparece quando há dado suficiente"): the
    /// leading category needs at least 2 pieces, and counts must actually differ.
    static func gapCategory(items: [ClothingItem]) -> ClothingCategory? {
        let counts = gapEligibleCategories.map { category in
            (category, items.filter { $0.category == category }.count)
        }
        guard let maxCount = counts.map(\.1).max(), maxCount >= 2 else { return nil }
        let minCount = counts.map(\.1).min()!
        guard maxCount != minCount else { return nil }
        return counts.first { $0.1 == minCount }?.0
    }

    /// Up to `limit` distinct example colors from the palette's recommended
    /// colors, for "Worth buying next" (REQ-4.4) — deduped to their nearest
    /// named `ClothingColorSwatch` so two close RGB values don't read as two
    /// different suggestions.
    static func suggestedSwatches(recommendedColors: [ClosetColor], limit: Int = 3) -> [ClothingColorSwatch] {
        var seen = Set<ClothingColorSwatch>()
        var result: [ClothingColorSwatch] = []
        for color in recommendedColors {
            let swatch = ClothingColorSwatch.nearest(to: color)
            guard seen.insert(swatch).inserted else { continue }
            result.append(swatch)
            if result.count == limit { break }
        }
        return result
    }
}
