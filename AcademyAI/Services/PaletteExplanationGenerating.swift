import FoundationModels

@Generable
struct PaletteExplanation {
    @Guide(description: "A warm, encouraging 3-4 sentence explanation. First say why this subseason fits, in terms of the person's undertone, depth and intensity — plain words, never numbers or hex codes. Then say why the colors to avoid wash them out. Advisor tone, never clinical or judgmental.")
    let text: String
}

protocol PaletteExplanationGenerating {
    func generateExplanation(
        season: Season,
        axes: ColorimetryAxes,
        recommendedColors: [ClosetColor],
        avoidColors: [ClosetColor]
    ) async throws -> String
}

struct FoundationModelsPaletteExplainer: PaletteExplanationGenerating {
    func generateExplanation(
        season: Season,
        axes: ColorimetryAxes,
        recommendedColors: [ClosetColor],
        avoidColors: [ClosetColor]
    ) async throws -> String {
        let session = LanguageModelSession()
        let prompt = """
        The person's colorimetry subseason is \(season.displayName).
        Their coloring reads as: \(axes.plainLanguageSummary).
        Explain warmly why this subseason fits them, using those traits, \
        and why colors outside their palette wash them out.
        """
        let response = try await session.respond(to: prompt, generating: PaletteExplanation.self)
        return response.content.text
    }
}
