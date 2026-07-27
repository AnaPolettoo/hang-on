import SwiftData

/// One container shared by the app and its App Intents.
///
/// Intents that answer without opening the app run outside the SwiftUI
/// environment, so they can't reach the container the way a View does — they
/// read through here instead.
enum AppModelContainer {
    static let shared: ModelContainer = {
        do {
            return try ModelContainer(for: UserColorimetryProfile.self, ClothingItem.self, PurchaseCheck.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}
