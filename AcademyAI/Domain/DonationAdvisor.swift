import Foundation
import SwiftData

/// Decides which catalogued pieces are worth suggesting for donation, and
/// which of the three signals (forgotten, off-palette, duplicate) each one
/// satisfies. Pure Swift, no SwiftData import beyond the `ClothingItem` type
/// it reads, no side effects — `now` is always injected, never read
/// internally, so results are deterministic under test.
enum DonationAdvisor {
    static let forgottenThresholdDays = 90
    static let duplicateThreshold = 3

    struct Candidate: Equatable {
        let item: ClothingItem
        let isForgotten: Bool
        let isOffPalette: Bool
        let isDuplicate: Bool
        let daysSinceWorn: Int

        static func == (lhs: Candidate, rhs: Candidate) -> Bool {
            lhs.item.persistentModelID == rhs.item.persistentModelID
                && lhs.isForgotten == rhs.isForgotten
                && lhs.isOffPalette == rhs.isOffPalette
                && lhs.isDuplicate == rhs.isDuplicate
                && lhs.daysSinceWorn == rhs.daysSinceWorn
        }
    }

    /// `[]` when nobody in the closet has ever logged a wear (REQ-F.7) —
    /// without any time signal at all, letting the other two criteria decide
    /// alone would reintroduce the false positives REQ-F.2 exists to prevent.
    static func candidates(
        items: [ClothingItem],
        now: Date = .now,
        forgottenThresholdDays: Int = DonationAdvisor.forgottenThresholdDays,
        duplicateThreshold: Int = DonationAdvisor.duplicateThreshold
    ) -> [Candidate] {
        guard items.contains(where: { $0.lastWornDate != nil }) else { return [] }

        return items.compactMap { item in
            // REQ-F.1.1: a piece that was never individually logged can never
            // be a candidate, even if other pieces in the closet have logs and
            // even if this piece is off-palette and duplicated — nil means
            // "unknown", not "old". Without this, a duplicate off-palette
            // piece bought yesterday would qualify on day one.
            guard let lastWornDate = item.lastWornDate else { return nil }

            let daysSinceWorn = Calendar.current.dateComponents([.day], from: lastWornDate, to: now).day ?? 0
            let isForgotten = daysSinceWorn >= forgottenThresholdDays
            let isOffPalette = item.matchesColorimetry == false && !ClothingColorSwatch.nearest(to: item.dominantColor).isNeutral
            let isDuplicate = duplicateCount(of: item, in: items) >= duplicateThreshold

            let satisfiedCount = [isForgotten, isOffPalette, isDuplicate].filter { $0 }.count
            guard satisfiedCount >= 2 else { return nil }

            return Candidate(item: item, isForgotten: isForgotten, isOffPalette: isOffPalette, isDuplicate: isDuplicate, daysSinceWorn: daysSinceWorn)
        }
    }

    private static func duplicateCount(of item: ClothingItem, in items: [ClothingItem]) -> Int {
        let swatch = ClothingColorSwatch.nearest(to: item.dominantColor)
        return items.filter {
            $0.persistentModelID != item.persistentModelID
                && $0.category == item.category
                && ClothingColorSwatch.nearest(to: $0.dominantColor) == swatch
        }.count
    }
}
