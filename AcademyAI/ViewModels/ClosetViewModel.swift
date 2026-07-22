import Foundation
import SwiftData
import CoreGraphics
import ImageIO
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

    func classify(image: CGImage, orientation: CGImagePropertyOrientation) async -> ClothingClassification? {
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }

        do {
            return try await classifier.classify(image, orientation: orientation)
        } catch {
            errorMessage = "Não conseguimos identificar a peça. Tenta de novo com mais luz."
            return nil
        }
    }

    func saveItem(imageData: Data, category: ClothingCategory, colorSwatch: ClothingColorSwatch) {
        // A failed classify() call earlier leaves its error message behind; without
        // clearing it here, a save that succeeds right after still reads as a failure
        // to every caller that gates on `errorMessage == nil` (AddPieceView's "+ Add
        // this piece", AddClothingItemMenu's onAdded) — the piece gets persisted, but
        // the UI stays stuck on the review screen looking like nothing happened.
        errorMessage = nil
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
