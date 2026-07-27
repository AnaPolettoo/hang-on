import Foundation
import Observation

@Observable
final class PaletteExplanationViewModel {
    let season: Season
    let recommended: [ClosetColor]
    let explanation: String

    init(season: Season, recommended: [ClosetColor], explanation: String) {
        self.season = season
        self.recommended = recommended
        self.explanation = explanation
    }
}
