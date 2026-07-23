import Foundation

enum PurchaseRecommendation: Equatable {
    case worthIt
    case alreadyOwned
    case skipIt

    static func evaluate(matchesColorimetry: Bool?, fillsGap: Bool?) -> PurchaseRecommendation {
        // A color mismatch alone no longer forces a skip — a real gap (fillsGap == true,
        // or nil when the closet's still empty) can outweigh being off-palette. Skip is
        // reserved for the confirmed-worst case: wrong color AND a duplicate already owned.
        guard fillsGap == false else { return .worthIt }
        return matchesColorimetry == false ? .skipIt : .alreadyOwned
    }

    var title: String {
        switch self {
        case .worthIt: return "Worth it"
        case .alreadyOwned: return "You already have this"
        case .skipIt: return "Skip this one"
        }
    }

    var subtitle: String {
        switch self {
        case .worthIt: return "A solid pick for your closet"
        case .alreadyOwned: return "You've already got this covered"
        case .skipIt: return "Likely to gather dust"
        }
    }

    /// SF Symbol shown in the recommendation card / Recent Checks row.
    var symbolName: String {
        switch self {
        case .worthIt: return "checkmark.circle.fill"
        case .alreadyOwned: return "checkmark.circle.fill"
        case .skipIt: return "xmark.circle.fill"
        }
    }

    /// Compact glyph prefix for the Recent Checks row subtitle ("✕ Skip this one").
    var glyphPrefix: String {
        switch self {
        case .worthIt: return "✓"
        case .alreadyOwned: return "≈"
        case .skipIt: return "✕"
        }
    }
}
