import Foundation
import SwiftData
import CoreGraphics
import ImageIO
import Observation

struct ProcessedPhoto {
    let image: CGImage
    let classification: ClothingClassification
}

@MainActor
@Observable
final class ClosetViewModel {
    var items: [ClothingItem] = []
    var profileName: String?
    var isProcessing = false
    var errorMessage: String?

    private let classifier: ClothingClassifying
    private let backgroundRemover: BackgroundRemoving
    private let modelContext: ModelContext

    init(
        classifier: ClothingClassifying = VisionClothingClassifier(),
        backgroundRemover: BackgroundRemoving = VisionBackgroundRemover(),
        modelContext: ModelContext
    ) {
        self.classifier = classifier
        self.backgroundRemover = backgroundRemover
        self.modelContext = modelContext
        loadItems()
    }

    func loadItems() {
        let descriptor = FetchDescriptor<ClothingItem>(sortBy: [SortDescriptor(\.dateAdded, order: .reverse)])
        items = (try? modelContext.fetch(descriptor)) ?? []
        profileName = (try? modelContext.fetch(FetchDescriptor<UserColorimetryProfile>()))?.first?.name
    }

    func processPhoto(_ image: CGImage, orientation: CGImagePropertyOrientation) async -> ProcessedPhoto? {
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }

        // Bake orientation once; everything downstream (removal, classify, the saved
        // image) then works in `.up` space, so the composite never comes out sideways.
        let upright = ImageOrientation.upright(image, orientation: orientation)

        // Background removal is a best-effort enhancement: if Vision finds no subject
        // (or throws), fall back to the upright original — never block the flow.
        let removal = try? await backgroundRemover.removeBackground(from: upright)
        let finalImage = removal?.image ?? upright

        do {
            let classification = try await classifier.classify(finalImage, orientation: .up, mask: removal?.mask)
            return ProcessedPhoto(image: finalImage, classification: classification)
        } catch {
            errorMessage = "We couldn't identify the piece. Try again with more light."
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
            errorMessage = "Couldn't save the piece. Try again."
        }
    }
}
