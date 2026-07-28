import FoundationModels

@Generable
struct DonationSuggestionText {
    @Guide(description: "1-2 warm sentences suggesting this piece might be worth donating, grounded only in the specific reasons given — mention only the reasons that actually apply (forgotten, off-palette, or duplicated), never all three generically if only some apply. Advisor tone, gentle, never a command; the person decides, this only suggests.")
    let text: String
}

protocol DonationExplanationGenerating {
    func generateSuggestion(
        category: ClothingCategory,
        color: ClosetColor,
        isForgotten: Bool,
        daysSinceWorn: Int,
        isOffPalette: Bool,
        isDuplicate: Bool
    ) async throws -> String
}

struct FoundationModelsDonationExplainer: DonationExplanationGenerating {
    func generateSuggestion(
        category: ClothingCategory,
        color: ClosetColor,
        isForgotten: Bool,
        daysSinceWorn: Int,
        isOffPalette: Bool,
        isDuplicate: Bool
    ) async throws -> String {
        try ModelAvailabilityGate.check()
        let session = LanguageModelSession()
        let colorName = ClothingColorSwatch.nearest(to: color).displayName
        let pieceDescription = "\(colorName.lowercased()) \(category.rawValue)"

        var facts: [String] = []
        if isForgotten {
            facts.append("it hasn't been worn in \(daysSinceWorn) days")
        }
        if isOffPalette {
            facts.append("it falls outside the person's color palette")
        }
        if isDuplicate {
            facts.append("they already own several very similar pieces")
        }

        let prompt = """
        A person's \(pieceDescription) is a candidate for donating, because: \(facts.joined(separator: "; ")).
        Give a short, warm, gentle suggestion that they consider donating it, grounded only in the reasons listed above. Never command or insist — they decide.
        """

        let response = try await session.respond(to: prompt, generating: DonationSuggestionText.self)
        return response.content.text
    }
}
