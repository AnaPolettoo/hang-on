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

    /// Existing pieces sharing both the candidate's category and its nearest
    /// `ClothingColorSwatch` — the same match rule `fillsGap` uses, but returning
    /// the items themselves (for the Verdict screen's thumbnail row) instead of
    /// collapsing them to a Bool. Empty (not nil) when the closet has pieces but
    /// none match — nil-vs-empty ambiguity isn't needed here since the caller
    /// already has `fillsGap` for the "closet is empty" signal.
    static func similarItems(candidateCategory: ClothingCategory, candidateColor: ClosetColor, existingItems: [ClothingItem]) -> [ClothingItem] {
        let candidateSwatch = ClothingColorSwatch.nearest(to: candidateColor)
        return existingItems.filter { item in
            item.category == candidateCategory && ClothingColorSwatch.nearest(to: item.dominantColor) == candidateSwatch
        }
    }
}
