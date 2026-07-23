import Foundation
import SwiftData
import CoreGraphics
import ImageIO
import Observation

struct ProcessedPurchaseCheck {
    let image: CGImage
    let classification: ClothingClassification
    let matchesColorimetry: Bool?
    let fillsGap: Bool?
    let motivo: String
    let recomendacao: String
}

@MainActor
@Observable
final class PurchaseCheckViewModel {
    var isProcessing = false
    var errorMessage: String?
    /// Set by the "Essa peça vale a pena comprar?" App Intent (REQ-3.10) after it
    /// switches the tab bar to Check; the view resets this back to false once it
    /// has opened the camera, so it only auto-launches once per intent trigger.
    var pendingAutoLaunchCamera = false

    // Vision's top classification confidence below this reads as "background/lighting
    // too uncontrolled to trust" (decisão em aberto #1 do doc de produto) — below it we
    // skip the Foundation Models call entirely and ask for a retry instead of generating
    // a veredito from a shaky read. Heuristic threshold, not yet measured against real
    // store photos — revisit once Fluxo 3 is prototyped on-device.
    private static let lowConfidenceThreshold: Float = 0.15

    private let classifier: ClothingClassifying
    private let backgroundRemover: BackgroundRemoving
    private let verdictGenerator: PurchaseVerdictGenerating
    private let modelContext: ModelContext

    init(
        classifier: ClothingClassifying = VisionClothingClassifier(),
        backgroundRemover: BackgroundRemoving = VisionBackgroundRemover(),
        verdictGenerator: PurchaseVerdictGenerating = FoundationModelsPurchaseVerdictGenerator(),
        modelContext: ModelContext
    ) {
        self.classifier = classifier
        self.backgroundRemover = backgroundRemover
        self.verdictGenerator = verdictGenerator
        self.modelContext = modelContext
    }

    func checkPiece(_ image: CGImage, orientation: CGImagePropertyOrientation) async -> ProcessedPurchaseCheck? {
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }

        let upright = ImageOrientation.upright(image, orientation: orientation)
        let removal = try? await backgroundRemover.removeBackground(from: upright)
        let finalImage = removal?.image ?? upright

        do {
            let classification = try await classifier.classify(finalImage, orientation: .up, mask: removal?.mask)
            guard classification.confidence >= Self.lowConfidenceThreshold else {
                errorMessage = "Não conseguimos ver a peça direito. Aproxime só dela, sem o fundo da loja ao redor."
                return nil
            }

            let profile = try? modelContext.fetch(FetchDescriptor<UserColorimetryProfile>()).first
            let matches = ColorimetryMatcher.matches(color: classification.dominantColor, profile: profile)

            let existingItems = (try? modelContext.fetch(FetchDescriptor<ClothingItem>())) ?? []
            let fillsGap = GapAnalyzer.fillsGap(candidateCategory: classification.category, candidateColor: classification.dominantColor, existingItems: existingItems)

            let verdict = try await verdictGenerator.generateVerdict(
                category: classification.category,
                color: classification.dominantColor,
                matchesColorimetry: matches,
                fillsGap: fillsGap
            )

            return ProcessedPurchaseCheck(
                image: finalImage,
                classification: classification,
                matchesColorimetry: matches,
                fillsGap: fillsGap,
                motivo: verdict.motivo,
                recomendacao: verdict.recomendacao
            )
        } catch {
            errorMessage = "Não conseguimos identificar a peça. Tenta de novo com mais luz."
            return nil
        }
    }

    func recordDecision(
        imageData: Data,
        category: ClothingCategory,
        dominantColor: ClosetColor,
        matchesColorimetry: Bool?,
        fillsGap: Bool?,
        verdictText: String,
        decision: PurchaseDecision
    ) {
        errorMessage = nil
        let check = PurchaseCheck(
            imageData: imageData,
            category: category,
            dominantColor: dominantColor,
            matchesColorimetry: matchesColorimetry,
            fillsGap: fillsGap,
            verdictText: verdictText,
            decision: decision
        )
        modelContext.insert(check)

        if decision == .comprou {
            let item = ClothingItem(
                imageData: imageData,
                category: category,
                dominantColor: dominantColor,
                matchesColorimetry: matchesColorimetry,
                acquiredViaPurchaseCheck: true,
                linkedPurchaseCheckId: check.id
            )
            modelContext.insert(item)
        }

        do {
            try modelContext.save()
        } catch {
            errorMessage = "Não foi possível salvar a checagem. Tenta de novo."
        }
    }
}
