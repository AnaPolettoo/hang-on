import Foundation
import SwiftData

// Same constraint as ClothingItem/UserColorimetryProfile: SwiftData's composite-attribute
// schema generation crashes on a stored property of a custom Codable struct type, so
// `dominantColor` is JSON-encoded Data with a computed accessor.
@Model
final class PurchaseCheck {
    @Attribute(.unique) var id: UUID
    var imageData: Data
    var category: ClothingCategory
    private var dominantColorData: Data
    var matchesColorimetry: Bool?
    var fillsGap: Bool?
    var verdictText: String
    var decision: PurchaseDecision
    var dateChecked: Date

    var dominantColor: ClosetColor {
        get { Self.decodeColor(dominantColorData) }
        set { dominantColorData = Self.encodeColor(newValue) }
    }

    init(
        id: UUID = UUID(),
        imageData: Data,
        category: ClothingCategory,
        dominantColor: ClosetColor,
        matchesColorimetry: Bool?,
        fillsGap: Bool?,
        verdictText: String,
        decision: PurchaseDecision,
        dateChecked: Date = .now
    ) {
        self.id = id
        self.imageData = imageData
        self.category = category
        self.dominantColorData = Self.encodeColor(dominantColor)
        self.matchesColorimetry = matchesColorimetry
        self.fillsGap = fillsGap
        self.verdictText = verdictText
        self.decision = decision
        self.dateChecked = dateChecked
    }

    private static func encodeColor(_ color: ClosetColor) -> Data {
        (try? JSONEncoder().encode(color)) ?? Data()
    }

    private static func decodeColor(_ data: Data) -> ClosetColor {
        (try? JSONDecoder().decode(ClosetColor.self, from: data)) ?? ClosetColor(red: 0, green: 0, blue: 0)
    }
}
