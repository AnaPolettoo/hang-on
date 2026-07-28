import Foundation
import FoundationModels

@Generable
struct PurchaseVerdictText {
    @Guide(description: "1-2 warm sentences explaining why this piece does or doesn't fit — weighing BOTH the palette match and the wardrobe gap together, never the color alone. Name the actual category and color instead of generic terms. Vary the phrasing and reasoning across different pieces rather than reusing the same sentence template. Advisor tone, like a trusted stylist friend, never clinical, never a blocker.")
    let motivo: String

    @Guide(description: "1 encouraging sentence recommending or gently cautioning — grounded in the specific reason just given, not a generic restatement of it. Never forbidding; the person decides either way, this only advises.")
    let recomendacao: String
}

struct PurchaseVerdict {
    let motivo: String
    let recomendacao: String
}

protocol PurchaseVerdictGenerating {
    func generateVerdict(category: ClothingCategory, color: ClosetColor, matchesColorimetry: Bool?, fillsGap: Bool?, similarItemsCount: Int) async throws -> PurchaseVerdict
}

struct FoundationModelsPurchaseVerdictGenerator: PurchaseVerdictGenerating {
    func generateVerdict(category: ClothingCategory, color: ClosetColor, matchesColorimetry: Bool?, fillsGap: Bool?, similarItemsCount: Int) async throws -> PurchaseVerdict {
        try ModelAvailabilityGate.check()
        let session = LanguageModelSession()
        let colorName = ClothingColorSwatch.nearest(to: color).displayName
        let pieceDescription = "\(colorName.lowercased()) \(category.rawValue)"

        let paletteFact = matchesColorimetry.map {
            $0 ? "the \(pieceDescription) matches the person's color palette" : "the \(pieceDescription) falls outside the person's color palette"
        } ?? "the person hasn't done their colorimetry yet, so we can't tell if the \(pieceDescription) matches their palette"

        let gapFact = fillsGap.map { hasGap -> String in
            if hasGap {
                return "it would fill a real gap — they don't own anything like it yet"
            } else if similarItemsCount > 1 {
                return "they already own \(similarItemsCount) similar pieces, so it would be a duplicate"
            } else {
                return "they already own a very similar piece, so it would be a duplicate"
            }
        } ?? "the person's closet is still empty, so we can't tell if it fills a gap"

        let prompt = """
        A person is considering buying a \(pieceDescription). \(paletteFact.capitalized). \(gapFact.capitalized).
        Weigh both facts together rather than the color alone — a real wardrobe gap can make a piece worth buying even if it's off-palette, and an on-palette piece can still be worth skipping if it's a duplicate. Give a short, warm stylist's verdict grounded in these specific facts, never blocking the purchase decision.
        """

        let response = try await session.respond(to: prompt, generating: PurchaseVerdictText.self)
        return PurchaseVerdict(motivo: response.content.motivo, recomendacao: response.content.recomendacao)
    }
}
