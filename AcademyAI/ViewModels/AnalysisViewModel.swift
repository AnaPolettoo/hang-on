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

    var gapCategory: ClothingCategory? { WardrobeAnalyzer.gapCategory(items: items) }

    var suggestedSwatches: [ClothingColorSwatch] {
        guard gapCategory != nil, let profile else { return [] }
        return WardrobeAnalyzer.suggestedSwatches(recommendedColors: profile.recommendedColors)
    }

    var offPaletteItems: [ClothingItem] { items.filter { $0.matchesColorimetry == false } }
}
