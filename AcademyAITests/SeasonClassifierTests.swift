import Testing
@testable import AcademyAI

struct SeasonClassifierTests {
    // Uma âncora por subestação. Cada trinca foi escolhida para cair
    // inequivocamente numa das 12 células de (undertone, valor, banda).
    @Test func clearSpring() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.95, green: 0.65, blue: 0.35),
                eyeColor: ClosetColor(red: 0.25, green: 0.45, blue: 0.55),
                hairColor: ClosetColor(red: 0.58, green: 0.43, blue: 0.24)
            ) == .clearSpring
        )
    }

    @Test func warmSpring() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.88, green: 0.68, blue: 0.50),
                eyeColor: ClosetColor(red: 0.50, green: 0.42, blue: 0.30),
                hairColor: ClosetColor(red: 0.58, green: 0.44, blue: 0.30)
            ) == .warmSpring
        )
    }

    @Test func lightSpring() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.93, green: 0.83, blue: 0.72),
                eyeColor: ClosetColor(red: 0.68, green: 0.66, blue: 0.58),
                hairColor: ClosetColor(red: 0.80, green: 0.72, blue: 0.58)
            ) == .lightSpring
        )
    }

    @Test func deepAutumn() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.62, green: 0.42, blue: 0.22),
                eyeColor: ClosetColor(red: 0.22, green: 0.14, blue: 0.08),
                hairColor: ClosetColor(red: 0.20, green: 0.12, blue: 0.06)
            ) == .deepAutumn
        )
    }

    @Test func warmAutumn() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.70, green: 0.52, blue: 0.34),
                eyeColor: ClosetColor(red: 0.38, green: 0.30, blue: 0.20),
                hairColor: ClosetColor(red: 0.42, green: 0.30, blue: 0.18)
            ) == .warmAutumn
        )
    }

    @Test func softAutumn() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.66, green: 0.57, blue: 0.50),
                eyeColor: ClosetColor(red: 0.46, green: 0.41, blue: 0.36),
                hairColor: ClosetColor(red: 0.48, green: 0.42, blue: 0.36)
            ) == .softAutumn
        )
    }

    @Test func coolSummer() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.80, green: 0.40, blue: 0.52),
                eyeColor: ClosetColor(red: 0.24, green: 0.30, blue: 0.40),
                hairColor: ClosetColor(red: 0.68, green: 0.62, blue: 0.64)
            ) == .coolSummer
        )
    }

    @Test func lightSummer() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.88, green: 0.72, blue: 0.76),
                eyeColor: ClosetColor(red: 0.36, green: 0.40, blue: 0.46),
                hairColor: ClosetColor(red: 0.70, green: 0.66, blue: 0.66)
            ) == .lightSummer
        )
    }

    @Test func softSummer() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.78, green: 0.68, blue: 0.70),
                eyeColor: ClosetColor(red: 0.52, green: 0.52, blue: 0.52),
                hairColor: ClosetColor(red: 0.60, green: 0.56, blue: 0.56)
            ) == .softSummer
        )
    }

    @Test func clearWinter() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.72, green: 0.40, blue: 0.48),
                eyeColor: ClosetColor(red: 0.14, green: 0.16, blue: 0.22),
                hairColor: ClosetColor(red: 0.10, green: 0.09, blue: 0.11)
            ) == .clearWinter
        )
    }

    @Test func coolWinter() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.62, green: 0.44, blue: 0.48),
                eyeColor: ClosetColor(red: 0.20, green: 0.20, blue: 0.24),
                hairColor: ClosetColor(red: 0.18, green: 0.16, blue: 0.18)
            ) == .coolWinter
        )
    }

    @Test func deepWinter() {
        #expect(
            SeasonClassifier.classify(
                skinTone: ClosetColor(red: 0.44, green: 0.36, blue: 0.38),
                eyeColor: ClosetColor(red: 0.22, green: 0.21, blue: 0.22),
                hairColor: ClosetColor(red: 0.20, green: 0.19, blue: 0.20)
            ) == .deepWinter
        )
    }

    // A tabela (undertone, valor, banda) -> subestação, exercitada direto,
    // sem passar pela derivação dos eixos.
    @Test func everyAxisCombinationMapsToADistinctSeason() {
        let combinations: [(Bool, Bool, Double, Double)] = [
            (true, true, 0.60, 0.40), (true, true, 0.40, 0.24), (true, true, 0.20, 0.18),
            (true, false, 0.60, 0.40), (true, false, 0.40, 0.24), (true, false, 0.20, 0.18),
            (false, true, 0.60, 0.40), (false, true, 0.40, 0.24), (false, true, 0.20, 0.18),
            (false, false, 0.60, 0.40), (false, false, 0.40, 0.24), (false, false, 0.20, 0.18)
        ]
        let seasons = combinations.map {
            SeasonClassifier.season(
                for: ColorimetryAxes(isWarm: $0.0, isLight: $0.1, chroma: $0.2, contrast: $0.3)
            )
        }
        #expect(Set(seasons).count == 12)
        #expect(Set(seasons) == Set(Season.allCases))
    }

    @Test func classificationIsDeterministic() {
        let skin = ClosetColor(red: 0.70, green: 0.52, blue: 0.34)
        let eye = ClosetColor(red: 0.38, green: 0.30, blue: 0.20)
        let hair = ClosetColor(red: 0.42, green: 0.30, blue: 0.18)
        let first = SeasonClassifier.classify(skinTone: skin, eyeColor: eye, hairColor: hair)
        let second = SeasonClassifier.classify(skinTone: skin, eyeColor: eye, hairColor: hair)
        #expect(first == second)
    }
}
