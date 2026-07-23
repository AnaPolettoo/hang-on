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
            $0 ? "the piece matches the person's color palette" : "the piece falls outside the person's color palette"
        } ?? "the person hasn't done their colorimetry yet, so we can't tell if it matches their palette"

        let gapFact = fillsGap.map {
            $0 ? "it would fill a real gap in their wardrobe" : "it would duplicate a similar piece they already own"
        } ?? "the person's closet is still empty, so we can't tell if it fills a gap"

        let prompt = "A person is considering buying a \(category.rawValue) piece in \(colorName). \(paletteFact.capitalized). \(gapFact.capitalized). Give a short, warm stylist's verdict, never blocking the purchase decision."

        let response = try await session.respond(to: prompt, generating: PurchaseVerdictText.self)
        return PurchaseVerdict(motivo: response.content.motivo, recomendacao: response.content.recomendacao)
    }
}
