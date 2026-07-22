import Foundation
import SwiftData

// Same constraint as UserColorimetryProfile: SwiftData's composite-attribute
// schema generation crashes on a stored property of a custom Codable struct
// type, so `dominantColor` is JSON-encoded Data with a computed accessor.
@Model
final class ClothingItem {
    var imageData: Data
    var category: ClothingCategory
    private var dominantColorData: Data
    var matchesColorimetry: Bool?
    var acquiredViaPurchaseCheck: Bool
    var dateAdded: Date

    var dominantColor: ClosetColor {
        get { Self.decodeColor(dominantColorData) }
        set { dominantColorData = Self.encodeColor(newValue) }
    }

    init(
        imageData: Data,
        category: ClothingCategory,
        dominantColor: ClosetColor,
        matchesColorimetry: Bool?,
        acquiredViaPurchaseCheck: Bool = false,
        dateAdded: Date = .now
    ) {
        self.imageData = imageData
        self.category = category
        self.dominantColorData = Self.encodeColor(dominantColor)
        self.matchesColorimetry = matchesColorimetry
        self.acquiredViaPurchaseCheck = acquiredViaPurchaseCheck
        self.dateAdded = dateAdded
    }

    private static func encodeColor(_ color: ClosetColor) -> Data {
        (try? JSONEncoder().encode(color)) ?? Data()
    }

    private static func decodeColor(_ data: Data) -> ClosetColor {
        (try? JSONDecoder().decode(ClosetColor.self, from: data)) ?? ClosetColor(red: 0, green: 0, blue: 0)
    }
}
