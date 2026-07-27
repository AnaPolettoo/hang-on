import Testing
@testable import AcademyAI

struct ClothingClassificationTests {
    // O default existe para que os call sites e testes que não conhecem a flag
    // continuem compilando — mesma razão pela qual `confidence` tem default.
    @Test func isPatternedDefaultsToFalse() {
        let classification = ClothingClassification(
            category: .tops,
            dominantColor: .coral
        )
        #expect(!classification.isPatterned)
        #expect(classification.confidence == 1.0)
    }

    @Test func isPatternedIsCarriedWhenSet() {
        let classification = ClothingClassification(
            category: .tops,
            dominantColor: .coral,
            confidence: 0.8,
            isPatterned: true
        )
        #expect(classification.isPatterned)
    }
}
