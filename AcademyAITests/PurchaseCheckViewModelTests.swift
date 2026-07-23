import Foundation
import Testing
import SwiftData
import CoreGraphics
import ImageIO
@testable import AcademyAI

private struct FakeClothingClassifier: ClothingClassifying {
    let result: ClothingClassification
    func classify(_ image: CGImage, orientation: CGImagePropertyOrientation, mask: CGImage? = nil) async throws -> ClothingClassification { result }
}

private struct StubBackgroundRemover: BackgroundRemoving {
    let result: BackgroundRemovalResult?
    func removeBackground(from image: CGImage) async throws -> BackgroundRemovalResult? { result }
}

private struct FakeVerdictGenerator: PurchaseVerdictGenerating {
    let verdict: PurchaseVerdict
    func generateVerdict(category: ClothingCategory, color: ClosetColor, matchesColorimetry: Bool?, fillsGap: Bool?) async throws -> PurchaseVerdict { verdict }
}

private func makeSolidColorImage(size: Int = 8) -> CGImage {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    var pixelData = [UInt8](repeating: 0, count: size * size * 4)
    for i in stride(from: 0, to: pixelData.count, by: 4) {
        pixelData[i] = 200; pixelData[i + 1] = 100; pixelData[i + 2] = 90; pixelData[i + 3] = 255
    }
    let context = CGContext(
        data: &pixelData, width: size, height: size, bitsPerComponent: 8,
        bytesPerRow: size * 4, space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    return context.makeImage()!
}

@MainActor
struct PurchaseCheckViewModelTests {
    @Test func checkPieceReturnsVerdictForConfidentClassification() async throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let classifier = FakeClothingClassifier(result: ClothingClassification(category: .tops, dominantColor: .lime, confidence: 0.8))
        let verdictGenerator = FakeVerdictGenerator(verdict: PurchaseVerdict(motivo: "Combina bem com sua paleta.", recomendacao: "Vale a pena levar."))
        let viewModel = PurchaseCheckViewModel(classifier: classifier, backgroundRemover: StubBackgroundRemover(result: nil), verdictGenerator: verdictGenerator, modelContext: ModelContext(container))

        let result = await viewModel.checkPiece(makeSolidColorImage(), orientation: .up)

        #expect(result?.classification.category == .tops)
        #expect(result?.motivo == "Combina bem com sua paleta.")
        #expect(viewModel.errorMessage == nil)
    }

    @Test func checkPieceSkipsVerdictWhenConfidenceIsLow() async throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let classifier = FakeClothingClassifier(result: ClothingClassification(category: .tops, dominantColor: .lime, confidence: 0.05))
        let verdictGenerator = FakeVerdictGenerator(verdict: PurchaseVerdict(motivo: "x", recomendacao: "y"))
        let viewModel = PurchaseCheckViewModel(classifier: classifier, backgroundRemover: StubBackgroundRemover(result: nil), verdictGenerator: verdictGenerator, modelContext: ModelContext(container))

        let result = await viewModel.checkPiece(makeSolidColorImage(), orientation: .up)

        #expect(result == nil)
        #expect(viewModel.errorMessage != nil)
    }

    @Test func checkPieceComputesGapAsNilWithEmptyCloset() async throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let classifier = FakeClothingClassifier(result: ClothingClassification(category: .tops, dominantColor: .lime, confidence: 0.9))
        let verdictGenerator = FakeVerdictGenerator(verdict: PurchaseVerdict(motivo: "x", recomendacao: "y"))
        let viewModel = PurchaseCheckViewModel(classifier: classifier, backgroundRemover: StubBackgroundRemover(result: nil), verdictGenerator: verdictGenerator, modelContext: ModelContext(container))

        let result = await viewModel.checkPiece(makeSolidColorImage(), orientation: .up)

        #expect(result?.fillsGap == nil)
    }

    @Test func recordDecisionSavesPurchaseCheckWithoutCatalogingOnPass() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let classifier = FakeClothingClassifier(result: ClothingClassification(category: .tops, dominantColor: .lime, confidence: 0.9))
        let viewModel = PurchaseCheckViewModel(classifier: classifier, verdictGenerator: FakeVerdictGenerator(verdict: PurchaseVerdict(motivo: "x", recomendacao: "y")), modelContext: context)

        viewModel.recordDecision(imageData: Data([0x01]), category: .tops, dominantColor: .lime, matchesColorimetry: true, fillsGap: true, verdictText: "x\n\ny", decision: .naoComprou)

        let checks = try context.fetch(FetchDescriptor<PurchaseCheck>())
        #expect(checks.count == 1)
        #expect(checks.first?.decision == .naoComprou)
        let items = try context.fetch(FetchDescriptor<ClothingItem>())
        #expect(items.isEmpty)
    }

    @Test func recordDecisionCatalogsItemWhenBought() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let classifier = FakeClothingClassifier(result: ClothingClassification(category: .tops, dominantColor: .lime, confidence: 0.9))
        let viewModel = PurchaseCheckViewModel(classifier: classifier, verdictGenerator: FakeVerdictGenerator(verdict: PurchaseVerdict(motivo: "x", recomendacao: "y")), modelContext: context)

        viewModel.recordDecision(imageData: Data([0x01]), category: .tops, dominantColor: .lime, matchesColorimetry: true, fillsGap: true, verdictText: "x\n\ny", decision: .comprou)

        let items = try context.fetch(FetchDescriptor<ClothingItem>())
        #expect(items.count == 1)
        #expect(items.first?.acquiredViaPurchaseCheck == true)
        let checks = try context.fetch(FetchDescriptor<PurchaseCheck>())
        #expect(items.first?.linkedPurchaseCheckId == checks.first?.id)
    }

    @Test func checkPieceIncludesSimilarItemsWhenClosetHasMatches() async throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let existing = ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: nil)
        context.insert(existing)
        try context.save()

        let classifier = FakeClothingClassifier(result: ClothingClassification(category: .tops, dominantColor: .lime, confidence: 0.9))
        let viewModel = PurchaseCheckViewModel(classifier: classifier, verdictGenerator: FakeVerdictGenerator(verdict: PurchaseVerdict(motivo: "x", recomendacao: "y")), modelContext: context)

        let result = await viewModel.checkPiece(makeSolidColorImage(), orientation: .up)

        #expect(result?.similarItems.count == 1)
    }

    @Test func loadHistoryComputesStatsAndRecentChecks() throws {
        let container = try ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let classifier = FakeClothingClassifier(result: ClothingClassification(category: .tops, dominantColor: .lime, confidence: 0.9))
        let viewModel = PurchaseCheckViewModel(classifier: classifier, verdictGenerator: FakeVerdictGenerator(verdict: PurchaseVerdict(motivo: "x", recomendacao: "y")), modelContext: context)

        viewModel.recordDecision(imageData: Data([0x01]), category: .tops, dominantColor: .lime, matchesColorimetry: true, fillsGap: true, verdictText: "x", decision: .comprou)
        viewModel.recordDecision(imageData: Data([0x02]), category: .bottoms, dominantColor: .navy, matchesColorimetry: false, fillsGap: nil, verdictText: "y", decision: .naoComprou)

        #expect(viewModel.checkedCount == 2)
        #expect(viewModel.boughtCount == 1)
        #expect(viewModel.passedCount == 1)
        #expect(viewModel.recentChecks.count == 2)
    }
}
