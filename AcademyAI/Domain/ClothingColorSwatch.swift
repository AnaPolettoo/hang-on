import Foundation

/// The 12 named colors offered on the Add-Piece review screen (Figma node
/// 2091:10110), so a person corrects Vision's detected color to one of a
/// small, recognizable set instead of an arbitrary continuous RGB value.
enum ClothingColorSwatch: String, CaseIterable {
    case cream, brown, indigo, navy, white, red, taupe, grey, yellow, teal, pink, black

    var displayName: String {
        switch self {
        case .cream: return "Cream"
        case .brown: return "Brown"
        case .indigo: return "Indigo"
        case .navy: return "Navy"
        case .white: return "White"
        case .red: return "Red"
        case .taupe: return "Taupe"
        case .grey: return "Grey"
        case .yellow: return "Yellow"
        case .teal: return "Teal"
        case .pink: return "Pink"
        case .black: return "Black"
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
        }
    }

    static func nearest(to color: ClosetColor) -> ClothingColorSwatch {
        allCases.min { squaredDistance($0.color, color) < squaredDistance($1.color, color) }!
    }

    private static func squaredDistance(_ a: ClosetColor, _ b: ClosetColor) -> Double {
        let dr = a.red - b.red, dg = a.green - b.green, db = a.blue - b.blue
        return dr * dr + dg * dg + db * db
    }
}
