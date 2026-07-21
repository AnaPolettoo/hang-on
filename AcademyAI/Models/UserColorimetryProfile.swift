import Foundation
import SwiftData

@Model
final class UserColorimetryProfile {
    var name: String?
    var skinToneSample: ClothingColor
    var eyeColorSample: ClothingColor
    var hairColorSample: ClothingColor
    var season: Season
    var recommendedColors: [ClothingColor]
    var avoidColors: [ClothingColor]
    var createdAt: Date

    init(
        name: String?,
        skinToneSample: ClothingColor,
        eyeColorSample: ClothingColor,
        hairColorSample: ClothingColor,
        season: Season,
        recommendedColors: [ClothingColor],
        avoidColors: [ClothingColor],
        createdAt: Date = .now
    ) {
        self.name = name
        self.skinToneSample = skinToneSample
        self.eyeColorSample = eyeColorSample
        self.hairColorSample = hairColorSample
        self.season = season
        self.recommendedColors = recommendedColors
        self.avoidColors = avoidColors
        self.createdAt = createdAt
    }
}
