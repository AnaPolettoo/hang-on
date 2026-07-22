import Foundation
import SwiftData
import CoreGraphics
import Observation

@MainActor
@Observable
final class ClosetViewModel {
    var items: [ClothingItem] = []
    var profileName: String?
    var isProcessing = false
    var errorMessage: String?

    private let classifier: ClothingClassifying
    private let modelContext: ModelContext

    init(classifier: ClothingClassifying = VisionClothingClassifier(), modelContext: ModelContext) {
        self.classifier = classifier
        self.modelContext = modelContext
        loadItems()
    }

    func loadItems() {
        let descriptor = FetchDescriptor<ClothingItem>(sortBy: [SortDescriptor(\.dateAdded, order: .reverse)])
        items = (try? modelContext.fetch(descriptor)) ?? []
        profileName = (try? modelContext.fetch(FetchDescriptor<UserColorimetryProfile>()))?.first?.name
    }

    func addItem(image: CGImage, imageData: Data) async {
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }

        do {
            let classification = try await classifier.classify(image)
            let profile = try? modelContext.fetch(FetchDescriptor<UserColorimetryProfile>()).first
            let matches = ColorimetryMatcher.matches(color: classification.dominantColor, profile: profile)

            let item = ClothingItem(
                imageData: imageData,
                category: classification.category,
                dominantColor: classification.dominantColor,
                matchesColorimetry: matches
            )
            modelContext.insert(item)
            try modelContext.save()
            loadItems()
        } catch {
            errorMessage = "Não conseguimos identificar a peça. Tenta de novo com mais luz."
        }
    }
}
