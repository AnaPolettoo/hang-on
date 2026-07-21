import Testing
@testable import AcademyAI

struct SeasonClassifierTests {
    @Test func warmAndLightClassifiesAsSpring() {
        let skin = ClothingColor(red: 0.85, green: 0.65, blue: 0.55) // warm, light
        let eye = ClothingColor(red: 0.4, green: 0.3, blue: 0.2)
        let hair = ClothingColor(red: 0.6, green: 0.4, blue: 0.25) // light warm brown
        #expect(SeasonClassifier.classify(skinTone: skin, eyeColor: eye, hairColor: hair) == .spring)
    }

    @Test func warmAndDeepClassifiesAsAutumn() {
        let skin = ClothingColor(red: 0.65, green: 0.45, blue: 0.35) // warm, mid
        let eye = ClothingColor(red: 0.3, green: 0.2, blue: 0.1)
        let hair = ClothingColor(red: 0.15, green: 0.08, blue: 0.05) // deep warm brown
        #expect(SeasonClassifier.classify(skinTone: skin, eyeColor: eye, hairColor: hair) == .autumn)
    }

    @Test func coolAndLightClassifiesAsSummer() {
        let skin = ClothingColor(red: 0.75, green: 0.7, blue: 0.78) // cool (blue >= red), light
        let eye = ClothingColor(red: 0.4, green: 0.45, blue: 0.55)
        let hair = ClothingColor(red: 0.55, green: 0.5, blue: 0.5) // light ash
        #expect(SeasonClassifier.classify(skinTone: skin, eyeColor: eye, hairColor: hair) == .summer)
    }

    @Test func coolAndDeepClassifiesAsWinter() {
        let skin = ClothingColor(red: 0.55, green: 0.5, blue: 0.58) // cool, mid
        let eye = ClothingColor(red: 0.1, green: 0.1, blue: 0.15)
        let hair = ClothingColor(red: 0.05, green: 0.05, blue: 0.06) // deep cool black
        #expect(SeasonClassifier.classify(skinTone: skin, eyeColor: eye, hairColor: hair) == .winter)
    }

    @Test func classificationIsDeterministic() {
        let skin = ClothingColor(red: 0.65, green: 0.45, blue: 0.35)
        let eye = ClothingColor(red: 0.3, green: 0.2, blue: 0.1)
        let hair = ClothingColor(red: 0.15, green: 0.08, blue: 0.05)
        let first = SeasonClassifier.classify(skinTone: skin, eyeColor: eye, hairColor: hair)
        let second = SeasonClassifier.classify(skinTone: skin, eyeColor: eye, hairColor: hair)
        #expect(first == second)
    }
}
