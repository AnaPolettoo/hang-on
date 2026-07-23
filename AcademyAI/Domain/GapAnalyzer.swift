import Foundation

enum GapAnalyzer {
    /// `nil` when the closet has no catalogued pieces yet (REQ-3.4 — no gap signal
    /// available). Otherwise `true` when no existing `ClothingItem` shares both the
    /// candidate's category and its nearest `ClothingColorSwatch` (a real gap),
    /// `false` when one already does (a duplicate in quantity).
    static func fillsGap(candidateCategory: ClothingCategory, candidateColor: ClosetColor, existingItems: [ClothingItem]) -> Bool? {
        guard !existingItems.isEmpty else { return nil }

        let candidateSwatch = ClothingColorSwatch.nearest(to: candidateColor)
        let isDuplicate = existingItems.contains { item in
            item.category == candidateCategory && ClothingColorSwatch.nearest(to: item.dominantColor) == candidateSwatch
        }
        return !isDuplicate
    }
}
