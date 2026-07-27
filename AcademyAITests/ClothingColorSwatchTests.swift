import Testing
@testable import AcademyAI

private func hex(_ value: String) -> ClosetColor {
    func channel(_ i: Int) -> Double {
        Double(UInt8(value.dropFirst(1 + i * 2).prefix(2), radix: 16)!) / 255
    }
    return ClosetColor(red: channel(0), green: channel(1), blue: channel(2))
}

struct ClothingColorSwatchTests {
    // Estas cores foram extraídas de fotos reais de peças e, com os 12 swatches
    // originais e distância RGB, caíam todas em cinza/creme — o vocabulário não
    // tinha azul claro, e a distância RGB confunde clareza com matiz.
    @Test func lightBluesAreNotCalledGreyOrCream() {
        #expect(ClothingColorSwatch.nearest(to: hex("#78C6F0")) == .lightBlue)
        #expect(ClothingColorSwatch.nearest(to: hex("#B6D0EB")) == .lightBlue)
        #expect(ClothingColorSwatch.nearest(to: hex("#CCD4F0")) == .lightBlue)
        #expect(ClothingColorSwatch.nearest(to: hex("#B0C8D7")) == .lightBlue)
    }

    @Test func huesMissingFromTheOriginalTwelveNowHaveAName() {
        #expect(ClothingColorSwatch.nearest(to: hex("#3E7A4F")) == .green)
        #expect(ClothingColorSwatch.nearest(to: hex("#D96B2C")) == .orange)
        #expect(ClothingColorSwatch.nearest(to: hex("#7B5EA7")) == .purple)
    }

    // Bege caía em `pink` com distância RGB: as duas são claras, e a distância
    // euclidiana em RGB pesa clareza acima de matiz.
    @Test func beigeReadsAsCreamNotPink() {
        #expect(ClothingColorSwatch.nearest(to: hex("#CFC8B9")) == .cream)
    }

    // As cores que já funcionavam continuam funcionando.
    @Test func previouslyCorrectColorsAreUnchanged() {
        #expect(ClothingColorSwatch.nearest(to: hex("#161313")) == .black)
        #expect(ClothingColorSwatch.nearest(to: hex("#755147")) == .brown)
        #expect(ClothingColorSwatch.nearest(to: hex("#8F6955")) == .taupe)
        #expect(ClothingColorSwatch.nearest(to: hex("#4A576D")) == .navy)
    }

    @Test func everySwatchMapsToItself() {
        for swatch in ClothingColorSwatch.allCases {
            #expect(ClothingColorSwatch.nearest(to: swatch.color) == swatch)
        }
    }
}
