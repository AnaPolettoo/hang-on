import Testing
@testable import AcademyAI

struct ClothingCategoryMapperTests {
    @Test func mapsShirtIdentifierToTops() {
        #expect(ClothingCategoryMapper.category(forIdentifiers: ["jersey", "sweater"]) == .tops)
    }

    @Test func mapsJeanIdentifierToBottoms() {
        #expect(ClothingCategoryMapper.category(forIdentifiers: ["jean", "denim"]) == .bottoms)
    }

    @Test func mapsCoatIdentifierToOuterwear() {
        #expect(ClothingCategoryMapper.category(forIdentifiers: ["overcoat", "parka"]) == .outerwear)
    }

    @Test func mapsSneakerIdentifierToShoes() {
        #expect(ClothingCategoryMapper.category(forIdentifiers: ["sneaker"]) == .shoes)
    }

    @Test func unmatchedIdentifiersFallBackToOther() {
        #expect(ClothingCategoryMapper.category(forIdentifiers: ["balloon", "kite"]) == .other)
    }

    @Test func emptyIdentifiersFallBackToOther() {
        #expect(ClothingCategoryMapper.category(forIdentifiers: []) == .other)
    }

    @Test func firstMatchingIdentifierWinsOverLaterOnes() {
        #expect(ClothingCategoryMapper.category(forIdentifiers: ["sneaker", "jean"]) == .shoes)
    }
}
