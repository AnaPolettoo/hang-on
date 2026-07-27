import Testing
@testable import AcademyAI

struct GarmentLabelMapperTests {
    @Test func mapsTrainedLabelToMatchingCategory() {
        #expect(GarmentLabelMapper.category(forLabel: "tops", confidence: 0.9) == .tops)
        #expect(GarmentLabelMapper.category(forLabel: "bottoms", confidence: 0.9) == .bottoms)
        #expect(GarmentLabelMapper.category(forLabel: "outerwear", confidence: 0.9) == .outerwear)
        #expect(GarmentLabelMapper.category(forLabel: "dresses", confidence: 0.9) == .dresses)
        #expect(GarmentLabelMapper.category(forLabel: "shoes", confidence: 0.9) == .shoes)
    }

    @Test func lowConfidenceFallsBackToOther() {
        #expect(GarmentLabelMapper.category(forLabel: "tops", confidence: 0.2) == .other)
    }

    @Test func confidenceExactlyAtThresholdIsAccepted() {
        let atThreshold = GarmentLabelMapper.confidenceThreshold
        #expect(GarmentLabelMapper.category(forLabel: "shoes", confidence: atThreshold) == .shoes)
    }

    @Test func unknownLabelFallsBackToOther() {
        #expect(GarmentLabelMapper.category(forLabel: "balloon", confidence: 0.99) == .other)
    }

    @Test func emptyLabelFallsBackToOther() {
        #expect(GarmentLabelMapper.category(forLabel: "", confidence: 0.99) == .other)
    }

    // O modelo nunca prevê `other` (não é classe treinada) — se algum dia
    // previr, não pode virar categoria válida por acidente.
    @Test func otherIsNeverAcceptedAsATrainedLabel() {
        #expect(GarmentLabelMapper.category(forLabel: "other", confidence: 0.99) == .other)
    }
}
