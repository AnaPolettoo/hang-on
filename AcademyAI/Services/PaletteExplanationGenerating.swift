import FoundationModels

@Generable
struct PaletteExplanation {
    @Guide(description: "A warm, encouraging 2-3 sentence explanation of why these colors suit the person. Advisor tone, never clinical or judgmental. No hex codes or technical jargon.")
    let text: String
}

protocol PaletteExplanationGenerating {
    func generateExplanation(season: Season, recommendedColors: [ClosetColor]) async throws -> String
}

struct FoundationModelsPaletteExplainer: PaletteExplanationGenerating {
    func generateExplanation(season: Season, recommendedColors: [ClosetColor]) async throws -> String {
        let session = LanguageModelSession()
        let prompt = "The person's colorimetry season is \(season.rawValue). Explain warmly, in 2-3 sentences, why this color palette suits them."
        let response = try await session.respond(to: prompt, generating: PaletteExplanation.self)
        return response.content.text
    }
}
