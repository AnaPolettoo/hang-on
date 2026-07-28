import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    var profileName: String?
    var season: Season?
    var paletteSwatches: [ClosetColor] = []
    var explanation = ""
    var checkedCount = 0
    var closetCount = 0

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadProfile()
    }

    func loadProfile() {
        let profile = try? modelContext.fetch(FetchDescriptor<UserColorimetryProfile>()).first
        profileName = profile?.name
        season = profile?.season
        paletteSwatches = profile?.recommendedColors ?? []
        explanation = profile?.explanationText ?? ""
        checkedCount = (try? modelContext.fetch(FetchDescriptor<PurchaseCheck>()))?.count ?? 0
        closetCount = (try? modelContext.fetch(FetchDescriptor<ClothingItem>()))?.count ?? 0
    }

    /// First letter of up to the first two words of the profile name, for the
    /// header avatar ("Ana Carolina" -> "AC"); "?" when there's no name yet.
    var profileInitials: String {
        guard let profileName, !profileName.isEmpty else { return "?" }
        let letters = profileName.split(separator: " ").prefix(2).compactMap(\.first)
        return String(letters).uppercased()
    }
}
