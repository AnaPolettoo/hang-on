import Foundation

/// Decides whether logging "I wore this" today should bump `wearCount`, and
/// formats the closet tile's relative label. Pure Swift, no SwiftData import —
/// both functions take their reference date as a parameter (REQ-W.7) instead
/// of reading `Date.now` internally, so tests stay deterministic.
enum WearTracker {
    /// `true` the first time a piece is logged, or when the previous log was on
    /// a different calendar day than `now`. `false` when `lastWorn` falls on the
    /// same day as `now` — a second tap that day only refreshes the date
    /// (REQ-W.4), so an accidental double-tap can't inflate the count.
    static func shouldIncrementCount(lastWorn: Date?, now: Date) -> Bool {
        guard let lastWorn else { return true }
        return !Calendar.current.isDate(lastWorn, inSameDayAs: now)
    }

    /// "worn 3 days ago"-style string for the closet tile (REQ-W.5). The
    /// absolute date isn't useful here — only recency is.
    static func relativeLabel(lastWorn: Date, now: Date = .now) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: lastWorn, relativeTo: now)
    }
}
