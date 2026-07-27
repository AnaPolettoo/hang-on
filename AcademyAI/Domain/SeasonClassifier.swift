import Foundation

enum SeasonClassifier {
    static func classify(skinTone: ClosetColor, eyeColor: ClosetColor, hairColor: ClosetColor) -> Season {
        season(for: ColorimetryAxes.from(skinTone: skinTone, eyeColor: eyeColor, hairColor: hairColor))
    }

    /// (undertone, depth) picks the family; the intensity band picks which of the
    /// family's three subseasons fits. Exhaustive by construction: 2 x 2 x 3 = 12.
    static func season(for axes: ColorimetryAxes) -> Season {
        switch (axes.isWarm, axes.isLight, axes.band) {
        case (true, true, .vivid): return .clearSpring
        case (true, true, .balanced): return .warmSpring
        case (true, true, .muted): return .lightSpring

        case (true, false, .vivid): return .deepAutumn
        case (true, false, .balanced): return .warmAutumn
        case (true, false, .muted): return .softAutumn

        case (false, true, .vivid): return .coolSummer
        case (false, true, .balanced): return .lightSummer
        case (false, true, .muted): return .softSummer

        case (false, false, .vivid): return .clearWinter
        case (false, false, .balanced): return .coolWinter
        case (false, false, .muted): return .deepWinter
        }
    }
}
