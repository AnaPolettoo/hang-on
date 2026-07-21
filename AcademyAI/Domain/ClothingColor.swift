import Foundation

struct ClothingColor: Codable, Equatable {
    let red: Double
    let green: Double
    let blue: Double
}

extension ClothingColor {
    static let coral = ClothingColor(red: 0.93, green: 0.51, blue: 0.42)
    static let peach = ClothingColor(red: 0.98, green: 0.78, blue: 0.63)
    static let turquoise = ClothingColor(red: 0.25, green: 0.80, blue: 0.75)
    static let golden = ClothingColor(red: 0.85, green: 0.65, blue: 0.20)

    static let softBlue = ClothingColor(red: 0.55, green: 0.65, blue: 0.80)
    static let lavender = ClothingColor(red: 0.70, green: 0.60, blue: 0.80)
    static let roseGray = ClothingColor(red: 0.75, green: 0.60, blue: 0.62)
    static let slate = ClothingColor(red: 0.40, green: 0.45, blue: 0.55)

    static let lime = ClothingColor(red: 0.78, green: 0.82, blue: 0.38)
    static let wine = ClothingColor(red: 0.27, green: 0.12, blue: 0.15)
    static let beige = ClothingColor(red: 0.965, green: 0.949, blue: 0.918)
    static let mauve = ClothingColor(red: 0.83, green: 0.41, blue: 0.51)

    static let icyBlue = ClothingColor(red: 0.75, green: 0.85, blue: 0.95)
    static let emerald = ClothingColor(red: 0.0, green: 0.5, blue: 0.4)
    static let trueRed = ClothingColor(red: 0.80, green: 0.05, blue: 0.10)
    static let deepBlack = ClothingColor(red: 0.05, green: 0.05, blue: 0.05)
}
