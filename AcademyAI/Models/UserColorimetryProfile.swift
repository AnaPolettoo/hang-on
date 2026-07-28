import Foundation
import SwiftData

// SwiftData's composite-attribute schema generation crashes (EXC_BREAKPOINT inside
// its Codable-encoding path) when a @Model has 2+ stored properties of the same
// custom Codable struct type, and also when a stored property is an array of a
// custom Codable struct. Every `ClosetColor`-shaped value here is therefore stored
// as JSON-encoded `Data` with a computed accessor, never as a native `ClosetColor`
// or `[ClosetColor]` stored property.
@Model
final class UserColorimetryProfile {
    var name: String?
    private var skinToneSampleData: Data
    private var eyeColorSampleData: Data
    private var hairColorSampleData: Data
    var season: Season
    private var recommendedColorsData: Data
    private var avoidColorsData: Data
    /// The Foundation Models paragraph explaining why the season/palette fits,
    /// generated once at onboarding (or retake) time and persisted here so the
    /// Profile screen can show it again without a fresh generation call.
    var explanationText: String = ""
    var createdAt: Date

    var skinToneSample: ClosetColor {
        get { Self.decodeColor(skinToneSampleData) }
        set { skinToneSampleData = Self.encodeColor(newValue) }
    }

    var eyeColorSample: ClosetColor {
        get { Self.decodeColor(eyeColorSampleData) }
        set { eyeColorSampleData = Self.encodeColor(newValue) }
    }

    var hairColorSample: ClosetColor {
        get { Self.decodeColor(hairColorSampleData) }
        set { hairColorSampleData = Self.encodeColor(newValue) }
    }

    var recommendedColors: [ClosetColor] {
        get { (try? JSONDecoder().decode([ClosetColor].self, from: recommendedColorsData)) ?? [] }
        set { recommendedColorsData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    var avoidColors: [ClosetColor] {
        get { (try? JSONDecoder().decode([ClosetColor].self, from: avoidColorsData)) ?? [] }
        set { avoidColorsData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    init(
        name: String?,
        skinToneSample: ClosetColor,
        eyeColorSample: ClosetColor,
        hairColorSample: ClosetColor,
        season: Season,
        recommendedColors: [ClosetColor],
        avoidColors: [ClosetColor],
        explanationText: String = "",
        createdAt: Date = .now
    ) {
        self.name = name
        self.skinToneSampleData = Self.encodeColor(skinToneSample)
        self.eyeColorSampleData = Self.encodeColor(eyeColorSample)
        self.hairColorSampleData = Self.encodeColor(hairColorSample)
        self.season = season
        self.recommendedColorsData = (try? JSONEncoder().encode(recommendedColors)) ?? Data()
        self.avoidColorsData = (try? JSONEncoder().encode(avoidColors)) ?? Data()
        self.explanationText = explanationText
        self.createdAt = createdAt
    }

    private static func encodeColor(_ color: ClosetColor) -> Data {
        (try? JSONEncoder().encode(color)) ?? Data()
    }

    private static func decodeColor(_ data: Data) -> ClosetColor {
        (try? JSONDecoder().decode(ClosetColor.self, from: data)) ?? ClosetColor(red: 0, green: 0, blue: 0)
    }
}
