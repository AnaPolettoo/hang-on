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

    func classify(image: CGImage) async -> ClothingClassification? {
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }

        do {
            return try await classifier.classify(image)
        } catch {
            errorMessage = "Não conseguimos identificar a peça. Tenta de novo com mais luz."
            return nil
        }
    }

    func saveItem(imageData: Data, category: ClothingCategory, colorSwatch: ClothingColorSwatch) {
        let color = colorSwatch.color
        let profile = try? modelContext.fetch(FetchDescriptor<UserColorimetryProfile>()).first
        let matches = ColorimetryMatcher.matches(color: color, profile: profile)

        let item = ClothingItem(
            imageData: imageData,
            category: category,
            dominantColor: color,
            matchesColorimetry: matches
        )
        modelContext.insert(item)
        do {
            try modelContext.save()
            loadItems()
        } catch {
            errorMessage = "Não foi possível salvar a peça. Tenta de novo."
        }
    }
}
