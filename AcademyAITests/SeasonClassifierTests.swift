import Testing
@testable import AcademyAI

struct SeasonClassifierTests {
    // Uma âncora por subestação. Cada trinca é uma combinação humana plausível
    // (pele na escala Fitzpatrick, cabelo e olho de cores reais), não um valor
    // construído para satisfazer a fórmula — foi assim que descobrimos que a
    // versão anterior, com croma na banda de intensidade, tornava três
    // subestações inalcançáveis para pessoas de verdade.

    // pele clara quente, cabelo loiro claro, olho castanho
    @Test func clearSpring() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 1.000, green: 0.878, blue: 0.741),
                eyeColor: ClosetColor(red: 0.373, green: 0.255, blue: 0.157),
                hairColor: ClosetColor(red: 0.914, green: 0.804, blue: 0.588)
            ) == .clearSpring
        )
    }

    // pele clara quente, cabelo loiro escuro, olho verde
    @Test func warmSpring() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.945, green: 0.761, blue: 0.569),
                eyeColor: ClosetColor(red: 0.431, green: 0.569, blue: 0.392),
                hairColor: ClosetColor(red: 0.722, green: 0.592, blue: 0.353)
            ) == .warmSpring
        )
    }

    // pele média quente, cabelo loiro escuro, olho azul
    @Test func lightSpring() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.878, green: 0.675, blue: 0.412),
                eyeColor: ClosetColor(red: 0.412, green: 0.588, blue: 0.745),
                hairColor: ClosetColor(red: 0.722, green: 0.592, blue: 0.353)
            ) == .lightSpring
        )
    }

    // pele média quente, cabelo preto, olho azul
    @Test func deepAutumn() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.878, green: 0.675, blue: 0.412),
                eyeColor: ClosetColor(red: 0.412, green: 0.588, blue: 0.745),
                hairColor: ClosetColor(red: 0.110, green: 0.086, blue: 0.078)
            ) == .deepAutumn
        )
    }

    // pele morena quente, cabelo preto, olho castanho
    @Test func warmAutumn() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.553, green: 0.333, blue: 0.141),
                eyeColor: ClosetColor(red: 0.373, green: 0.255, blue: 0.157),
                hairColor: ClosetColor(red: 0.110, green: 0.086, blue: 0.078)
            ) == .warmAutumn
        )
    }

    // pele escura quente, cabelo castanho escuro, olho castanho
    @Test func softAutumn() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.396, green: 0.224, blue: 0.086),
                eyeColor: ClosetColor(red: 0.373, green: 0.255, blue: 0.157),
                hairColor: ClosetColor(red: 0.294, green: 0.196, blue: 0.118)
            ) == .softAutumn
        )
    }

    // pele clara fria, cabelo loiro claro, olho castanho escuro
    @Test func coolSummer() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.941, green: 0.784, blue: 0.765),
                eyeColor: ClosetColor(red: 0.216, green: 0.149, blue: 0.110),
                hairColor: ClosetColor(red: 0.914, green: 0.804, blue: 0.588)
            ) == .coolSummer
        )
    }

    // pele clara fria, cabelo loiro claro, olho azul
    @Test func lightSummer() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.941, green: 0.784, blue: 0.765),
                eyeColor: ClosetColor(red: 0.412, green: 0.588, blue: 0.745),
                hairColor: ClosetColor(red: 0.914, green: 0.804, blue: 0.588)
            ) == .lightSummer
        )
    }

    // pele média fria, cabelo loiro escuro, olho azul
    @Test func softSummer() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.745, green: 0.549, blue: 0.510),
                eyeColor: ClosetColor(red: 0.412, green: 0.588, blue: 0.745),
                hairColor: ClosetColor(red: 0.722, green: 0.592, blue: 0.353)
            ) == .softSummer
        )
    }

    // pele média fria, cabelo preto, olho azul
    @Test func clearWinter() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.745, green: 0.549, blue: 0.510),
                eyeColor: ClosetColor(red: 0.412, green: 0.588, blue: 0.745),
                hairColor: ClosetColor(red: 0.110, green: 0.086, blue: 0.078)
            ) == .clearWinter
        )
    }

    // pele morena fria, cabelo castanho escuro, olho verde
    @Test func coolWinter() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.549, green: 0.373, blue: 0.353),
                eyeColor: ClosetColor(red: 0.431, green: 0.569, blue: 0.392),
                hairColor: ClosetColor(red: 0.294, green: 0.196, blue: 0.118)
            ) == .coolWinter
        )
    }

    // pele escura fria, cabelo castanho escuro, olho castanho
    @Test func deepWinter() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.373, green: 0.243, blue: 0.235),
                eyeColor: ClosetColor(red: 0.373, green: 0.255, blue: 0.157),
                hairColor: ClosetColor(red: 0.294, green: 0.196, blue: 0.118)
            ) == .deepWinter
        )
    }

    // A tabela (undertone, valor, banda) -> subestação, exercitada direto,
    // sem passar pela derivação dos eixos.
    @Test func everyAxisCombinationMapsToADistinctSeason() {
        let combinations: [(Bool, Bool, Double)] = [
            (true, true, 0.50), (true, true, 0.28), (true, true, 0.10),
            (true, false, 0.50), (true, false, 0.28), (true, false, 0.10),
            (false, true, 0.50), (false, true, 0.28), (false, true, 0.10),
            (false, false, 0.50), (false, false, 0.28), (false, false, 0.10)
        ]
        let seasons = combinations.map {
            SeasonClassifier.season(
                for: ColorimetryAxes(isWarm: $0.0, isLight: $0.1, chroma: 0.4, contrast: $0.2)
            )
        }
        #expect(Set(seasons).count == 12)
        #expect(Set(seasons) == Set(Season.allCases))
    }

    // O bug que motivou a reescrita do classificador: `(skin.red - skin.blue) > 0`
    // é verdadeiro para essencialmente toda pele humana, então a fórmula antiga
    // lia quase todo mundo como "quente" e as famílias frias eram inalcançáveis.
    @Test func rosySkinReachesACoolFamily() {
        let season = SeasonClassifier.classify(
            skinTone: ClosetColor(red: 0.941, green: 0.784, blue: 0.765),
            eyeColor: ClosetColor(red: 0.412, green: 0.588, blue: 0.745),
            hairColor: ClosetColor(red: 0.914, green: 0.804, blue: 0.588)
        )
        #expect([.coolSummer, .lightSummer, .softSummer, .coolWinter, .clearWinter, .deepWinter].contains(season))
    }

    @Test func classificationIsDeterministic() {
        let skin = ClosetColor(red: 0.553, green: 0.333, blue: 0.141)
        let eye = ClosetColor(red: 0.373, green: 0.255, blue: 0.157)
        let hair = ClosetColor(red: 0.110, green: 0.086, blue: 0.078)
        let first = SeasonClassifier.classify(skinTone: skin, eyeColor: eye, hairColor: hair)
        let second = SeasonClassifier.classify(skinTone: skin, eyeColor: eye, hairColor: hair)
        #expect(first == second)
    }
}
