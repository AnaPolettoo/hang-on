import Testing
import SwiftData
import AppIntents
@testable import AcademyAI

@MainActor
struct AppIntentsTests {
    private func makeContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: UserColorimetryProfile.self, ClothingItem.self, PurchaseCheck.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }

    // MARK: - My Palette

    @Test func paletteAnswerNamesTheSubseasonAndSpeaksTheColors() throws {
        let context = try makeContext()
        context.insert(UserColorimetryProfile(
            name: "Ana",
            skinToneSample: .beige, eyeColorSample: .wine, hairColorSample: .wine,
            season: .warmAutumn,
            recommendedColors: SeasonPalette.recommendedColors(for: .warmAutumn),
            avoidColors: SeasonPalette.avoidColors(for: .warmAutumn)
        ))
        try context.save()

        let answer = try IntentAnswers.palette(context: context)

        // O valor devolvido é a subestação sozinha, para um atalho ramificar nela.
        #expect(answer.season == "Warm Autumn")
        #expect(answer.spoken.hasPrefix("You're a Warm Autumn."))
        #expect(answer.spoken.contains("Your colors are"))
        // Sem números nem jargão: é uma frase falada em voz alta.
        let hasDigits = answer.spoken.contains(where: \.isNumber)
        #expect(!hasDigits)
    }

    @Test func paletteAnswerFailsClearlyWhenColorimetryWasNeverDone() throws {
        let context = try makeContext()

        var thrown: ClosetIntentError?
        do { _ = try IntentAnswers.palette(context: context) }
        catch let error as ClosetIntentError { thrown = error }
        #expect(thrown == .noColorimetryProfile)

        // O erro é o que a pessoa ouve — precisa dizer o que fazer, não só falhar.
        let message = String(localized: ClosetIntentError.noColorimetryProfile.localizedStringResource)
        #expect(message.contains("colorimetry test"))
    }

    // A frase falada precisa ler como frase, não como array.
    @Test func spokenColorListReadsNaturally() {
        #expect(IntentAnswers.listPhrase([]) == "")
        #expect(IntentAnswers.listPhrase(["rust"]) == "rust")
        #expect(IntentAnswers.listPhrase(["rust", "olive"]) == "rust and olive")
        #expect(IntentAnswers.listPhrase(["rust", "olive", "camel"]) == "rust, olive and camel")
    }

    // MARK: - Closet Summary

    @Test func closetSummaryCountsPiecesAndSharesInPalette() throws {
        let context = try makeContext()
        context.insert(ClothingItem(imageData: Data(), category: .tops, dominantColor: .rust, matchesColorimetry: true))
        context.insert(ClothingItem(imageData: Data(), category: .tops, dominantColor: .rust, matchesColorimetry: true))
        context.insert(ClothingItem(imageData: Data(), category: .bottoms, dominantColor: .icyBlue, matchesColorimetry: false))
        context.insert(ClothingItem(imageData: Data(), category: .shoes, dominantColor: .camel, matchesColorimetry: false))
        try context.save()

        let answer = try IntentAnswers.closetSummary(context: context)

        #expect(answer.pieces == 4)
        #expect(answer.spoken == "You have 4 pieces, and 50 percent of them are in your palette.")
    }

    @Test func closetSummarySaysPieceInTheSingular() throws {
        let context = try makeContext()
        context.insert(ClothingItem(imageData: Data(), category: .tops, dominantColor: .rust, matchesColorimetry: true))
        try context.save()

        let answer = try IntentAnswers.closetSummary(context: context)
        #expect(answer.spoken.contains("1 piece,"))
    }

    // Peças salvas antes da colorimetria não têm nota de paleta: o intent diz só
    // a contagem em vez de inventar uma porcentagem.
    @Test func closetSummaryOmitsThePercentageWhenNothingWasScored() throws {
        let context = try makeContext()
        context.insert(ClothingItem(imageData: Data(), category: .tops, dominantColor: .rust, matchesColorimetry: nil))
        try context.save()

        let answer = try IntentAnswers.closetSummary(context: context)

        #expect(answer.pieces == 1)
        #expect(!answer.spoken.contains("percent"))
    }

    @Test func closetSummaryFailsClearlyWhenTheClosetIsEmpty() throws {
        let context = try makeContext()

        var thrown: ClosetIntentError?
        do { _ = try IntentAnswers.closetSummary(context: context) }
        catch let error as ClosetIntentError { thrown = error }
        #expect(thrown == .emptyCloset)

        let message = String(localized: ClosetIntentError.emptyCloset.localizedStringResource)
        #expect(message.contains("empty"))
        #expect(message.contains("Add"))
    }

    // MARK: - Shortcuts

    // O conteúdo das frases não é verificável aqui: `AppShortcut` não expõe
    // `phrases` em runtime. Não é lacuna de cobertura — o Xcode valida a regra
    // que importa (toda frase precisa conter o nome do app) em tempo de build,
    // então uma frase malformada quebra a compilação, não os testes.
    @Test func everyIntentHasAShortcut() {
        #expect(AcademyAIShortcuts.appShortcuts.count == 3)
    }
}
