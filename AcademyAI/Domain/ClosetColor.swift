import Foundation

struct ClosetColor: Codable, Equatable {
    let red: Double
    let green: Double
    let blue: Double

    /// Relative luminance (perceptual weights), used to pick readable text over this color as a fill.
    var isDark: Bool {
        (0.299 * red + 0.587 * green + 0.114 * blue) <= 0.6
    }
}

extension ClosetColor {
    static let coral = ClosetColor(red: 0.93, green: 0.51, blue: 0.42)
    static let peach = ClosetColor(red: 0.98, green: 0.78, blue: 0.63)
    static let turquoise = ClosetColor(red: 0.25, green: 0.80, blue: 0.75)
    static let golden = ClosetColor(red: 0.85, green: 0.65, blue: 0.20)

    static let softBlue = ClosetColor(red: 0.55, green: 0.65, blue: 0.80)
    static let lavender = ClosetColor(red: 0.70, green: 0.60, blue: 0.80)
    static let roseGray = ClosetColor(red: 0.75, green: 0.60, blue: 0.62)
    static let slate = ClosetColor(red: 0.40, green: 0.45, blue: 0.55)

    // Exact values from the Figma file (color/yellow/62, /rose/19, /orange/90, /red/67).
    static let lime = ClosetColor(red: 0.812, green: 0.820, blue: 0.427)
    static let wine = ClosetColor(red: 0.251, green: 0.122, blue: 0.157)
    static let beige = ClosetColor(red: 0.949, green: 0.894, blue: 0.843)
    static let mauve = ClosetColor(red: 0.827, green: 0.518, blue: 0.573)

    static let icyBlue = ClosetColor(red: 0.75, green: 0.85, blue: 0.95)
    static let emerald = ClosetColor(red: 0.0, green: 0.5, blue: 0.4)
    static let trueRed = ClosetColor(red: 0.80, green: 0.05, blue: 0.10)
    static let deepBlack = ClosetColor(red: 0.05, green: 0.05, blue: 0.05)
}
