import Foundation

enum SeasonClassifier {
    static func classify(skinTone: ClothingColor, eyeColor: ClothingColor, hairColor: ClothingColor) -> Season {
        let isWarm = (skinTone.red - skinTone.blue) > 0
        let isLight = averageLuminance(skinTone, hairColor) > 0.55

        switch (isWarm, isLight) {
        case (true, true): return .spring
        case (true, false): return .autumn
        case (false, true): return .summer
        case (false, false): return .winter
        }
    }

    private static func averageLuminance(_ a: ClothingColor, _ b: ClothingColor) -> Double {
        (luminance(a) + luminance(b)) / 2
    }

    private static func luminance(_ color: ClothingColor) -> Double {
        0.299 * color.red + 0.587 * color.green + 0.114 * color.blue
    }
}
