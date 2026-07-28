import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class AnalysisViewModel {
    var items: [ClothingItem] = []
    var profile: UserColorimetryProfile?
    private(set) var donationSuggestions: [PersistentIdentifier: String] = [:]

    private let modelContext: ModelContext
    private let donationExplainer: DonationExplanationGenerating

    init(modelContext: ModelContext, donationExplainer: DonationExplanationGenerating = FoundationModelsDonationExplainer()) {
        self.modelContext = modelContext
        self.donationExplainer = donationExplainer
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

    /// Pieces worth suggesting for donation — see `DonationAdvisor` for the
    /// candidacy rule. Empty (never an empty *state*) when nothing qualifies
    /// or nobody in the closet has ever logged a wear (REQ-F.6/F.7).
    var donationCandidates: [DonationAdvisor.Candidate] {
        DonationAdvisor.candidates(items: items)
    }

    /// The generated suggestion sentence for a candidate, once loaded via
    /// `loadDonationSuggestion(for:)`. `nil` until then — the View shows a
    /// placeholder in that gap.
    func donationSuggestion(for item: ClothingItem) -> String? {
        donationSuggestions[item.persistentModelID]
    }

    /// Fetches and stores the donation suggestion sentence for one candidate.
    /// The candidacy decision (which criteria fired) is already made by
    /// `DonationAdvisor` — this only asks Foundation Models to phrase it
    /// (REQ-F.4).
    func loadDonationSuggestion(for candidate: DonationAdvisor.Candidate) async {
        guard let text = try? await donationExplainer.generateSuggestion(
            category: candidate.item.category,
            color: candidate.item.dominantColor,
            isForgotten: candidate.isForgotten,
            daysSinceWorn: candidate.daysSinceWorn,
            isOffPalette: candidate.isOffPalette,
            isDuplicate: candidate.isDuplicate
        ) else { return }
        donationSuggestions[candidate.item.persistentModelID] = text
    }

    /// First letter of up to the first two words of the profile name, for the
    /// header avatar ("Ana Carolina" -> "AC"); "?" when there's no name yet.
    var profileInitials: String {
        guard let name = profile?.name, !name.isEmpty else { return "?" }
        let letters = name.split(separator: " ").prefix(2).compactMap(\.first)
        return String(letters).uppercased()
    }
}
