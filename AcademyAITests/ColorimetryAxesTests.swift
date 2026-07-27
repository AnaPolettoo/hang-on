import Testing
@testable import AcademyAI

struct ColorimetryAxesTests {
    // Pele humana real tem sempre R > B — de porcelana a pele muito escura.
    // Estes dois casos são exatamente os que a fórmula antiga (`red - blue > 0`)
    // classificava como "quente" indistintamente; o matiz separa os dois.
    @Test func goldenSkinReadsAsWarm() {
        let axes = ColorimetryAxes.from(
            skinTone: ClosetColor(red: 0.95, green: 0.65, blue: 0.35),
            eyeColor: ClosetColor(red: 0.25, green: 0.45, blue: 0.55),
            hairColor: ClosetColor(red: 0.58, green: 0.43, blue: 0.24)
        )
        #expect(axes.isWarm)
    }

    @Test func rosySkinReadsAsCoolEvenThoughRedExceedsBlue() {
        let skin = ClosetColor(red: 0.80, green: 0.40, blue: 0.52)
        #expect(skin.red > skin.blue) // a fórmula antiga diria "quente" aqui
        let axes = ColorimetryAxes.from(
            skinTone: skin,
            eyeColor: ClosetColor(red: 0.24, green: 0.30, blue: 0.40),
            hairColor: ClosetColor(red: 0.68, green: 0.62, blue: 0.64)
        )
        #expect(!axes.isWarm)
    }

    @Test func lightnessAveragesSkinAndHair() {
        let light = ColorimetryAxes.from(
            skinTone: ClosetColor(red: 0.93, green: 0.83, blue: 0.72),
            eyeColor: ClosetColor(red: 0.68, green: 0.66, blue: 0.58),
            hairColor: ClosetColor(red: 0.80, green: 0.72, blue: 0.58)
        )
        #expect(light.isLight)

        let deep = ColorimetryAxes.from(
            skinTone: ClosetColor(red: 0.62, green: 0.42, blue: 0.22),
            eyeColor: ClosetColor(red: 0.22, green: 0.14, blue: 0.08),
            hairColor: ClosetColor(red: 0.20, green: 0.12, blue: 0.06)
        )
        #expect(!deep.isLight)
    }

    @Test func chromaIsSkinSaturation() {
        let vivid = ColorimetryAxes.from(
            skinTone: ClosetColor(red: 0.95, green: 0.65, blue: 0.35),
            eyeColor: ClosetColor(red: 0.25, green: 0.45, blue: 0.55),
            hairColor: ClosetColor(red: 0.58, green: 0.43, blue: 0.24)
        )
        // (0.95 - 0.35) / 0.95
        #expect(abs(vivid.chroma - 0.6316) < 0.001)
    }

    @Test func contrastIsLargestLuminanceGapAmongTheThreeSamples() {
        // Olho bem mais escuro que pele e cabelo: o par pele-olho domina.
        let axes = ColorimetryAxes.from(
            skinTone: ClosetColor(red: 0.88, green: 0.72, blue: 0.76),
            eyeColor: ClosetColor(red: 0.36, green: 0.40, blue: 0.46),
            hairColor: ClosetColor(red: 0.70, green: 0.66, blue: 0.66)
        )
        #expect(abs(axes.contrast - 0.378) < 0.005)
    }

    @Test func bandSplitsIntensityIntoThree() {
        let vivid = ColorimetryAxes(isWarm: true, isLight: true, chroma: 0.60, contrast: 0.40)
        #expect(vivid.band == .vivid)

        let balanced = ColorimetryAxes(isWarm: true, isLight: true, chroma: 0.40, contrast: 0.24)
        #expect(balanced.band == .balanced)

        let muted = ColorimetryAxes(isWarm: true, isLight: true, chroma: 0.20, contrast: 0.18)
        #expect(muted.band == .muted)
    }

    // Fronteiras: `vivid` exige `>`, `muted` exige `<`, então os dois valores
    // de corte exatos pertencem à banda `balanced`.
    @Test func intensityExactlyOnEitherThresholdIsBalanced() {
        let atVividCut = ColorimetryAxes(isWarm: true, isLight: true, chroma: 0.40, contrast: 0.40)
        #expect(atVividCut.intensity == 0.40)
        #expect(atVividCut.band == .balanced)

        let atMutedCut = ColorimetryAxes(isWarm: true, isLight: true, chroma: 0.25, contrast: 0.25)
        #expect(atMutedCut.intensity == 0.25)
        #expect(atMutedCut.band == .balanced)
    }

    @Test func plainLanguageSummaryHasNoNumbers() {
        let axes = ColorimetryAxes(isWarm: true, isLight: false, chroma: 0.60, contrast: 0.40)
        let summary = axes.plainLanguageSummary
        #expect(summary.contains("warm"))
        #expect(summary.contains("deep"))
        #expect(!summary.contains(where: { "0123456789".contains($0) }))
    }

    @Test func derivationIsDeterministic() {
        let skin = ClosetColor(red: 0.70, green: 0.52, blue: 0.34)
        let eye = ClosetColor(red: 0.38, green: 0.30, blue: 0.20)
        let hair = ClosetColor(red: 0.42, green: 0.30, blue: 0.18)
        #expect(
            ColorimetryAxes.from(skinTone: skin, eyeColor: eye, hairColor: hair)
                == ColorimetryAxes.from(skinTone: skin, eyeColor: eye, hairColor: hair)
        )
    }
}
