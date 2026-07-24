import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class AnalysisViewModel {
    var items: [ClothingItem] = []
    var profile: UserColorimetryProfile?

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadItems()
    }

    func loadItems() {
        let descriptor = FetchDescriptor<ClothingItem>(sortBy: [SortDescriptor(\.dateAdded, order: .reverse)])
        items = (try? modelContext.fetch(descriptor)) ?? []
        profile = try? modelContext.fetch(FetchDescriptor<UserColorimetryProfile>()).first
    }

    var totalCount: Int { items.count }

    var percentInPalette: Double? { WardrobeAnalyzer.percentInPalette(items: items) }

    var categoryCounts: [WardrobeAnalyzer.CategoryCount] { WardrobeAnalyzer.categoryCounts(items: items) }

    var gapInsight: WardrobeAnalyzer.GapInsight? { WardrobeAnalyzer.gapInsight(items: items) }

    var suggestedSwatches: [ClothingColorSwatch] {
        guard gapInsight != nil, let profile else { return [] }
        return WardrobeAnalyzer.suggestedSwatches(recommendedColors: profile.recommendedColors)
    }

    /// Off-palette pieces in a non-neutral color — genuinely worth reconsidering.
    var offPaletteItems: [ClothingItem] {
        items.filter { $0.matchesColorimetry == false && !ClothingColorSwatch.nearest(to: $0.dominantColor).isNeutral }
    }

    /// Off-palette pieces in a neutral color (black, white, grey, cream, taupe, navy, brown) —
    /// not in the palette, but still worth keeping since neutrals pair with everything.
    var neutralPieces: [ClothingItem] {
        items.filter { $0.matchesColorimetry == false && ClothingColorSwatch.nearest(to: $0.dominantColor).isNeutral }
    }

    /// First letter of up to the first two words of the profile name, for the
    /// header avatar ("Ana Carolina" -> "AC"); "?" when there's no name yet.
    var profileInitials: String {
        guard let name = profile?.name, !name.isEmpty else { return "?" }
        let letters = name.split(separator: " ").prefix(2).compactMap(\.first)
        return String(letters).uppercased()
    }
}
