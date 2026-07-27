import Foundation

/// The four axes professional colorimetry reads off a person, derived from the
/// three RGB samples the selfie pipeline already produces. Pure arithmetic — no
/// model, no randomness, so the same samples always give the same axes.
struct ColorimetryAxes: Equatable {
    /// Yellow-leaning skin hue (warm) vs. pink/blue-leaning (cool).
    let isWarm: Bool
    /// Overall depth, averaged across skin and hair.
    let isLight: Bool
    /// Skin saturation. Feeds the veredict text only — see `intensity` for why it
    /// is not part of the band that picks the subseason.
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
    private static let vividThreshold = 0.35
    private static let mutedThreshold = 0.22

    /// Contrast alone, deliberately — `chroma` is kept for the veredict text but
    /// stays out of this band.
    ///
    /// Folding chroma in here was measured against realistic skin tones and made
    /// three subseasons unreachable (`lightSpring`, `warmAutumn`, `softAutumn`),
    /// while deep skin collapsed onto `deepAutumn` alone. The reason is that
    /// chroma and undertone are not independent: "warm" in RGB *means* golden —
    /// green and blue well under red — which is high saturation by construction,
    /// so warm skin measured 0.26-0.78 chroma against 0.18-0.37 for cool skin and
    /// never landed in the muted band. Saturation also climbs with skin depth,
    /// pushing deep skin to "vivid" regardless of the person's actual contrast.
    ///
    /// Contrast — the luminance spread across skin, eyes and hair — is what
    /// actually separates clear/bright types from soft ones, and it doesn't track
    /// undertone. With it alone, all twelve subseasons are reachable and every
    /// skin tone can reach at least three.
    var intensity: Double {
        contrast
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
