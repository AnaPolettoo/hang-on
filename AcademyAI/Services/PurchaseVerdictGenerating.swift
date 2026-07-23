import Foundation
import FoundationModels

@Generable
struct PurchaseVerdictText {
    @Guide(description: "1-2 warm sentences explaining why this piece does or doesn't fit — referencing the palette match and/or the wardrobe gap when known. Advisor tone, like a trusted stylist friend, never clinical, never a blocker.")
    let motivo: String

    @Guide(description: "1 encouraging sentence recommending or gently cautioning — never forbidding. The person decides either way; this only advises.")
    let recomendacao: String
}

struct PurchaseVerdict {
    let motivo: String
    let recomendacao: String
}

protocol PurchaseVerdictGenerating {
    func generateVerdict(category: ClothingCategory, color: ClosetColor, matchesColorimetry: Bool?, fillsGap: Bool?) async throws -> PurchaseVerdict
}

struct FoundationModelsPurchaseVerdictGenerator: PurchaseVerdictGenerating {
    func generateVerdict(category: ClothingCategory, color: ClosetColor, matchesColorimetry: Bool?, fillsGap: Bool?) async throws -> PurchaseVerdict {
        let session = LanguageModelSession()
        let colorName = ClothingColorSwatch.nearest(to: color).displayName

        let paletteFact = matchesColorimetry.map {
            $0 ? "a peça combina com a paleta de cores da pessoa" : "a peça foge da paleta de cores da pessoa"
        } ?? "a colorimetria da pessoa ainda não foi feita, então não dá pra saber se combina com a paleta"

        let gapFact = fillsGap.map {
            $0 ? "ela preencheria uma lacuna real do guarda-roupa" : "ela duplicaria uma peça parecida que a pessoa já tem"
        } ?? "o guarda-roupa da pessoa ainda está vazio, então não dá pra saber se preenche uma lacuna"

        let prompt = "Uma pessoa está cogitando comprar uma peça de \(category.rawValue) na cor \(colorName). \(paletteFact.capitalized). \(gapFact.capitalized). Dê um veredito de estilista, curto e caloroso, sem nunca bloquear a decisão de compra."

        let response = try await session.respond(to: prompt, generating: PurchaseVerdictText.self)
        return PurchaseVerdict(motivo: response.content.motivo, recomendacao: response.content.recomendacao)
    }
}
