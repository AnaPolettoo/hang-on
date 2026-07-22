import Foundation
import Observation

@Observable
final class PaletteResultViewModel {
    let season: Season
    let recommended: [ClosetColor]
    let avoid: [ClosetColor]
    let explanation: String

    init(season: Season, recommended: [ClosetColor], avoid: [ClosetColor], explanation: String) {
        self.season = season
        self.recommended = recommended
        self.avoid = avoid
        self.explanation = explanation
    }
}
