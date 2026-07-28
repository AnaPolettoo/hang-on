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

    /// First letter of up to the first two words of the profile name, for the
    /// header avatar ("Ana Carolina" -> "AC"); "?" when there's no name yet.
    var profileInitials: String {
        guard let profileName, !profileName.isEmpty else { return "?" }
        let letters = profileName.split(separator: " ").prefix(2).compactMap(\.first)
        return String(letters).uppercased()
    }

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

    func saveItem(
        imageData: Data,
        category: ClothingCategory,
        colorSwatch: ClothingColorSwatch,
        isPatterned: Bool = false
    ) {
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
            matchesColorimetry: matches,
            isPatterned: isPatterned
        )
        modelContext.insert(item)
        do {
            try modelContext.save()
            loadItems()
        } catch {
            errorMessage = "Couldn't save the piece. Try again."
        }
    }

    func deleteItem(_ item: ClothingItem) {
        // Same errorMessage-clearing shape as saveItem: a stale message from an
        // earlier failed action shouldn't read as belonging to this delete.
        errorMessage = nil
        modelContext.delete(item)
        do {
            try modelContext.save()
            loadItems()
        } catch {
            errorMessage = "Couldn't delete the piece. Try again."
        }
    }

    func updateItem(
        _ item: ClothingItem,
        category: ClothingCategory,
        colorSwatch: ClothingColorSwatch,
        isPatterned: Bool
    ) {
        // Same errorMessage-clearing shape as saveItem/deleteItem.
        errorMessage = nil
        let profile = try? modelContext.fetch(FetchDescriptor<UserColorimetryProfile>()).first
        item.category = category
        item.dominantColor = colorSwatch.color
        item.isPatterned = isPatterned
        // Recompute rather than trust the old value: a color edit that didn't
        // recheck the palette would leave the piece silently mismarked (REQ-E.4).
        item.matchesColorimetry = ColorimetryMatcher.matches(color: colorSwatch.color, profile: profile)
        do {
            try modelContext.save()
            loadItems()
        } catch {
            errorMessage = "Couldn't save the piece. Try again."
        }
    }
}
