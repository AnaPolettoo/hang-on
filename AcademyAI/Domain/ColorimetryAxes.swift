import Foundation

/// The four axes professional colorimetry reads off a person, derived from the
/// three RGB samples the selfie pipeline already produces. Pure arithmetic — no
/// model, no randomness, so the same samples always give the same axes.
struct ColorimetryAxes: Equatable {
    /// Yellow-leaning skin hue (warm) vs. pink/blue-leaning (cool).
    let isWarm: Bool
    /// Overall depth, averaged across skin and hair.
    let isLight: Bool
    /// Skin saturation: high reads as clear/vivid, low as soft/muted.
    let chroma: Double
    /// Largest luminance gap among skin, eye and hair.
    let contrast: Double

    enum IntensityBand {
        case vivid, balanced, muted
    }

    // Skin hue in degrees. Human skin sits in the red-orange-yellow wedge, so the
    // split between warm and cool lives *inside* that wedge: above the lower bound
    // the tone leans golden, below it leans rosy. Samples whose dominant channel
    // isn't red land far outside the range and read as cool, which is correct.
    private static let warmHueRange = 20.0...70.0
    private static let lightnessThreshold = 0.55
    private static let vividThreshold = 0.40
    private static let mutedThreshold = 0.25

    /// Chroma and contrast pull in the same direction in real colorimetry: the
    /// "clear/bright" types are high in both, the "soft/muted" types low in both.
    var intensity: Double {
        (chroma + contrast) / 2
    }

    var band: IntensityBand {
        if intensity > Self.vividThreshold { return .vivid }
        if intensity < Self.mutedThreshold { return .muted }
        return .balanced
    }

    /// Feeds the veredict prompt. Words only — the person never sees the numbers.
    var plainLanguageSummary: String {
        let undertone = isWarm ? "warm" : "cool"
        let depth = isLight ? "light" : "deep"
        let intensityWord: String
        switch band {
        case .vivid: intensityWord = "vivid, high-contrast"
        case .balanced: intensityWord = "balanced"
        case .muted: intensityWord = "soft, low-contrast"
        }
        return "\(undertone) undertone, \(depth) overall, \(intensityWord)"
    }

    static func from(skinTone: ClosetColor, eyeColor: ClosetColor, hairColor: ClosetColor) -> ColorimetryAxes {
        let skinLuminance = luminance(skinTone)
        let eyeLuminance = luminance(eyeColor)
        let hairLuminance = luminance(hairColor)

        return ColorimetryAxes(
            isWarm: warmHueRange.contains(hueDegrees(skinTone)),
            isLight: (skinLuminance + hairLuminance) / 2 > lightnessThreshold,
            chroma: saturation(skinTone),
            contrast: max(
                abs(skinLuminance - hairLuminance),
                abs(skinLuminance - eyeLuminance),
                abs(hairLuminance - eyeLuminance)
            )
        )
    }

    private static func luminance(_ color: ClosetColor) -> Double {
        0.299 * color.red + 0.587 * color.green + 0.114 * color.blue
    }

    private static func saturation(_ color: ClosetColor) -> Double {
        let highest = max(color.red, color.green, color.blue)
        guard highest > 0 else { return 0 }
        return (highest - min(color.red, color.green, color.blue)) / highest
    }

    private static func hueDegrees(_ color: ClosetColor) -> Double {
        let highest = max(color.red, color.green, color.blue)
        let lowest = min(color.red, color.green, color.blue)
        let delta = highest - lowest
        guard delta > 0 else { return 0 }

        let hue: Double
        if highest == color.red {
            hue = 60 * ((color.green - color.blue) / delta)
        } else if highest == color.green {
            hue = 60 * ((color.blue - color.red) / delta + 2)
        } else {
            hue = 60 * ((color.red - color.green) / delta + 4)
        }
        return hue < 0 ? hue + 360 : hue
    }
}
