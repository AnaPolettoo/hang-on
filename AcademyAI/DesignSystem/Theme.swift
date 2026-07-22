import SwiftUI

/// Design tokens ported from the Figma file (Closet, node 24eGOEwSDQxLEySg4jg9lu).
enum Theme {
    enum Color {
        /// `color/red/15` — primary text, borders, and filled buttons.
        static let ink = SwiftUI.Color(hex: "2B1F22")
        /// `color/grey/98` — screen background.
        static let cream = SwiftUI.Color(hex: "FDFBF7")
        /// `color/red/15 40%` — secondary/placeholder text over cream.
        static let inkMuted = SwiftUI.Color(hex: "2B1F22").opacity(0.4)
        /// `color/red/67` — accent border (name field, selection states).
        static let accentBorder = SwiftUI.Color(hex: "D38492")
        /// `color/yellow/62` — accent fill for the "+ Add this piece" confirm action.
        static let accentYellow = SwiftUI.Color(hex: "CFD16D")
    }

    enum Font {
        /// `font family/Font 1` — the app's display/handwriting typeface throughout the Figma file.
        private static let familyName = "PatrickHand-Regular"

        static let display = SwiftUI.Font.custom(familyName, size: 44)
        static let largeTitle = SwiftUI.Font.custom(familyName, size: 30)
        static let sectionTitle = SwiftUI.Font.custom(familyName, size: 24)
        static let title = SwiftUI.Font.custom(familyName, size: 19)
        static let button = SwiftUI.Font.custom(familyName, size: 17)
        static let body = SwiftUI.Font.custom(familyName, size: 16)
        static let subheadline = SwiftUI.Font.custom(familyName, size: 15)
        static let caption = SwiftUI.Font.custom(familyName, size: 14)
    }

    enum Layout {
        static let cornerRadius: CGFloat = 12
        static let spacingXS: CGFloat = 8
        static let spacingXXS: CGFloat = 4
    }
}

extension SwiftUI.Color {
    init(hex: String) {
        var hexValue = UInt64()
        Scanner(string: hex).scanHexInt64(&hexValue)
        let red = Double((hexValue & 0xFF0000) >> 16) / 255
        let green = Double((hexValue & 0x00FF00) >> 8) / 255
        let blue = Double(hexValue & 0x0000FF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

/// A full-width, pill-shaped filled button matching the Figma "PrimaryBtn" component.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Font.button)
            .foregroundStyle(Theme.Color.cream)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Theme.Color.ink)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var closetPrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

/// A pill-shaped, dashed-border secondary button, matching the Figma "DashedBtn" component.
struct DashedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Font.button)
            .foregroundStyle(Theme.Color.ink.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .overlay(
                Capsule()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [4]))
                    .foregroundStyle(Theme.Color.ink.opacity(0.4))
            )
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

extension ButtonStyle where Self == DashedButtonStyle {
    static var closetDashed: DashedButtonStyle { DashedButtonStyle() }
}

/// A pill-shaped, filled accent button, matching the Figma "+ Add this piece" button.
struct AccentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Font.title)
            .foregroundStyle(Theme.Color.ink)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Theme.Color.accentYellow)
            .overlay(Capsule().stroke(Theme.Color.ink.opacity(0.2), lineWidth: 2))
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

extension ButtonStyle where Self == AccentButtonStyle {
    static var closetAccent: AccentButtonStyle { AccentButtonStyle() }
}
