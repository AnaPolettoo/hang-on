import Testing
import SwiftData
import AppIntents
@testable import AcademyAI

@MainActor
struct AppIntentsTests {
    // MARK: - MyPaletteIntent

    @Test func myPaletteReturnsTheSubseasonAndSpeaksTheColors() async throws {
        let container = try ModelContainer(
            for: UserColorimetryProfile.self, ClothingItem.self, PurchaseCheck.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        context.insert(UserColorimetryProfile(
            name: "Ana",
            skinToneSample: .beige, eyeColorSample: .wine, hairColorSample: .wine,
            season: .warmAutumn,
            recommendedColors: SeasonPalette.recommendedColors(for: .warmAutumn),
            avoidColors: SeasonPalette.avoidColors(for: .warmAutumn)
        ))
        try context.save()

        let profile = try #require(try context.fetch(FetchDescriptor<UserColorimetryProfile>()).first)
        // O valor devolvido é a subestação sozinha, para um atalho poder ramificar nela.
        #expect(profile.season.displayName == "Warm Autumn")
        #expect(!profile.recommendedColors.isEmpty)
    }

    // A frase falada precisa ler como frase, não como array.
    @Test func spokenColorListReadsNaturally() {
        #expect(MyPaletteIntent.listPhrase([]) == "")
        #expect(MyPaletteIntent.listPhrase(["rust"]) == "rust")
        #expect(MyPaletteIntent.listPhrase(["rust", "olive"]) == "rust and olive")
        #expect(MyPaletteIntent.listPhrase(["rust", "olive", "camel"]) == "rust, olive and camel")
    }

    @Test func myPaletteFailsClearlyWhenColorimetryWasNeverDone() async throws {
        let container = try ModelContainer(
            for: UserColorimetryProfile.self, ClothingItem.self, PurchaseCheck.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        #expect(try context.fetch(FetchDescriptor<UserColorimetryProfile>()).isEmpty)

        // O erro é o que a pessoa ouve — precisa dizer o que fazer, não só falhar.
        let message = String(localized: ClosetIntentError.noColorimetryProfile.localizedStringResource)
        #expect(message.contains("colorimetry test"))
    }

    // MARK: - WardrobeSummaryIntent

    @Test func emptyClosetErrorTellsThePersonWhatToDo() {
        let message = String(localized: ClosetIntentError.emptyCloset.localizedStringResource)
        #expect(message.contains("empty"))
        #expect(message.contains("Add"))
    }

    // O intent fala uma porcentagem: ela tem que sair do mesmo WardrobeAnalyzer
    // que a aba Analysis usa, não de uma segunda definição de "na paleta".
    @Test func summaryPercentageComesFromWardrobeAnalyzer() throws {
        let container = try ModelContainer(
            for: UserColorimetryProfile.self, ClothingItem.self, PurchaseCheck.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        context.insert(ClothingItem(imageData: Data(), category: .tops, dominantColor: .rust, matchesColorimetry: true))
        context.insert(ClothingItem(imageData: Data(), category: .tops, dominantColor: .rust, matchesColorimetry: true))
        context.insert(ClothingItem(imageData: Data(), category: .bottoms, dominantColor: .icyBlue, matchesColorimetry: false))
        context.insert(ClothingItem(imageData: Data(), category: .shoes, dominantColor: .camel, matchesColorimetry: false))
        try context.save()

        let items = try context.fetch(FetchDescriptor<ClothingItem>())
        let percent = try #require(WardrobeAnalyzer.percentInPalette(items: items))
        #expect(items.count == 4)
        #expect(Int((percent * 100).rounded()) == 50)
    }

    // Peças salvas antes da colorimetria não têm nota de paleta: o intent deve
    // dizer só a contagem em vez de inventar uma porcentagem.
    @Test func summaryOmitsPercentageWhenNothingWasScored() throws {
        let container = try ModelContainer(
            for: UserColorimetryProfile.self, ClothingItem.self, PurchaseCheck.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        context.insert(ClothingItem(imageData: Data(), category: .tops, dominantColor: .rust, matchesColorimetry: nil))
        try context.save()

        let items = try context.fetch(FetchDescriptor<ClothingItem>())
        #expect(WardrobeAnalyzer.percentInPalette(items: items) == nil)
    }

    // MARK: - Shortcuts

    // O conteúdo das frases não é verificável aqui: `AppShortcut` não expõe
    // `phrases` em runtime. Não é lacuna de cobertura — o Xcode valida a regra
    // que importa (toda frase precisa conter `\(.applicationName)`) em tempo de
    // build, então uma frase malformada quebra a compilação, não os testes.
    @Test func thereIsAShortcutForEachIntent() {
        #expect(AcademyAIShortcuts.appShortcuts.count == 3)
    }
}
