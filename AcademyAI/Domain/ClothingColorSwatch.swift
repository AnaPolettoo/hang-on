import Foundation

/// The named colors offered on the Add-Piece review screen, so a person corrects
/// the detected color to one of a small, recognizable set instead of an arbitrary
/// continuous RGB value.
///
/// The first twelve come from the Figma file (node 2091:10110). The last five were
/// added after measuring real garment photos: the original set had no light blue,
/// green, orange or purple, so a sky-blue shirt resolved to `grey` and baby-blue
/// jeans to `cream`. Across 200 pieces, 10% sat more than 0.25 (RGB distance) from
/// any swatch, and the distribution was lopsided — `navy` absorbed a quarter of
/// everything while `red` and `yellow` took one piece each.
enum ClothingColorSwatch: String, CaseIterable {
    case cream, brown, indigo, navy, white, red, taupe, grey, yellow, teal, pink, black
    case lightBlue, green, olive, orange, purple

    var displayName: String {
        switch self {
        case .cream: return String(localized: "Cream")
        case .brown: return String(localized: "Brown")
        case .indigo: return String(localized: "Indigo")
        case .navy: return String(localized: "Navy")
        case .white: return String(localized: "White")
        case .red: return String(localized: "Red")
        case .taupe: return String(localized: "Taupe")
        case .grey: return String(localized: "Grey")
        case .yellow: return String(localized: "Yellow")
        case .teal: return String(localized: "Teal")
        case .pink: return String(localized: "Pink")
        case .black: return String(localized: "Black")
        case .lightBlue: return String(localized: "Light Blue")
        case .green: return String(localized: "Green")
        case .olive: return String(localized: "Olive")
        case .orange: return String(localized: "Orange")
        case .purple: return String(localized: "Purple")
        }
    }

    // Exact values from the Figma file (color hex -> 0-1 RGB, node 2091:10110).
    var color: ClosetColor {
        switch self {
        case .cream: return ClosetColor(red: 0.949, green: 0.894, blue: 0.843)     // F2E4D7
        case .brown: return ClosetColor(red: 0.420, green: 0.227, blue: 0.165)     // 6B3A2A
        case .indigo: return ClosetColor(red: 0.239, green: 0.290, blue: 0.541)    // 3D4A8A
        case .navy: return ClosetColor(red: 0.102, green: 0.137, blue: 0.251)      // 1A2340
        case .white: return ClosetColor(red: 0.973, green: 0.965, blue: 0.949)     // F8F6F2
        case .red: return ClosetColor(red: 0.420, green: 0.122, blue: 0.165)  // 6B1F2A
        case .taupe: return ClosetColor(red: 0.620, green: 0.557, blue: 0.486)     // 9E8E7C
        case .grey: return ClosetColor(red: 0.604, green: 0.604, blue: 0.604)      // 9A9A9A
        case .yellow: return ClosetColor(red: 0.910, green: 0.831, blue: 0.302)    // E8D44D
        case .teal: return ClosetColor(red: 0.165, green: 0.502, blue: 0.502)      // 2A8080
        case .pink: return ClosetColor(red: 0.910, green: 0.627, blue: 0.690)      // E8A0B0
        case .black: return ClosetColor(red: 0.102, green: 0.102, blue: 0.102)     // 1A1A1A
        // Added after measuring real garment photos — see the type's doc comment.
        case .lightBlue: return ClosetColor(red: 0.659, green: 0.784, blue: 0.878) // A8C8E0
        case .green: return ClosetColor(red: 0.290, green: 0.486, blue: 0.306)     // 4A7C4E
        case .olive: return ClosetColor(red: 0.420, green: 0.420, blue: 0.227)     // 6B6B3A
        case .orange: return ClosetColor(red: 0.851, green: 0.447, blue: 0.173)    // D9722C
        case .purple: return ClosetColor(red: 0.420, green: 0.306, blue: 0.620)    // 6B4E9E
        }
    }

    /// Colors that read as neutral in fashion — they pair with almost anything,
    /// so a piece in one of these is worth keeping even when it's off-palette.
    var isNeutral: Bool {
        switch self {
        case .cream, .white, .black, .grey, .taupe, .navy, .brown, .olive: return true
        case .indigo, .red, .yellow, .teal, .pink, .lightBlue, .green, .orange, .purple: return false
        }
    }

    /// Nearest by CIELAB distance, not RGB. Euclidean distance in RGB weighs
    /// lightness so heavily that it confuses "light" with "similar" — beige
    /// resolved to `pink` and sky blue to `grey`, because both pairs are equally
    /// bright. Lab separates lightness from hue the way the eye does.
    static func nearest(to color: ClosetColor) -> ClothingColorSwatch {
        let target = lab(color)
        return allCases.min {
            squaredDistance(lab($0.color), target) < squaredDistance(lab($1.color), target)
        }!
    }

    private static func squaredDistance(_ a: (Double, Double, Double), _ b: (Double, Double, Double)) -> Double {
        let d0 = a.0 - b.0, d1 = a.1 - b.1, d2 = a.2 - b.2
        return d0 * d0 + d1 * d1 + d2 * d2
    }

    /// sRGB -> CIELAB, D65 white point.
    private static func lab(_ color: ClosetColor) -> (Double, Double, Double) {
        func linear(_ channel: Double) -> Double {
            channel > 0.04045 ? pow((channel + 0.055) / 1.055, 2.4) : channel / 12.92
        }
        let r = linear(color.red), g = linear(color.green), b = linear(color.blue)

        let x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047
        let y = 0.2126 * r + 0.7152 * g + 0.0722 * b
        let z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883

        func f(_ t: Double) -> Double {
            t > 0.008856 ? pow(t, 1.0 / 3.0) : 7.787 * t + 16.0 / 116.0
        }
        let fx = f(x), fy = f(y), fz = f(z)
        return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz))
    }
}
