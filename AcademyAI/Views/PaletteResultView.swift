import SwiftUI

struct PaletteResultView: View {
    let viewModel: PaletteResultViewModel
    let onStartChecking: () -> Void

    var body: some View {
        ZStack {
            Theme.Color.cream.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text(seasonTitle)
                    .font(Theme.Font.largeTitle)
                    .foregroundStyle(Theme.Color.ink)
                    .overlay(alignment: .bottomLeading) {
                        Rectangle()
                            .fill(Theme.Color.ink)
                            .frame(height: 2)
                            .offset(y: 4)
                    }
                    .padding(.top, 8)

                ForEach(Array(viewModel.recommended.enumerated()), id: \.offset) { _, color in
                    Text(colorName(for: color))
                        .font(Theme.Font.title)
                        .foregroundStyle(textColor(for: color))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(swiftUIColor(from: color))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                                .stroke(Theme.Color.ink, lineWidth: 1.5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius))
                }

                Text(viewModel.explanation)
                    .font(Theme.Font.body)
                    .foregroundStyle(Theme.Color.inkMuted)

                Spacer()

                Button("Start Checking", action: onStartChecking)
                    .buttonStyle(.closetPrimary)
            }
            .padding()
        }
    }

    private var seasonTitle: String {
        switch viewModel.season {
        case .spring: return "Warm Spring"
        case .summer: return "Cool Summer"
        case .autumn: return "Warm Autumn"
        case .winter: return "Cool Winter"
        }
    }

    private func colorName(for color: ClosetColor) -> String {
        switch color {
        case .lime: return "Lime — everyday base"
        case .wine: return "Wine — rich accent"
        case .beige: return "Beige — neutral"
        case .mauve: return "Mauve — pop of color"
        case .coral: return "Coral"
        case .peach: return "Peach"
        case .turquoise: return "Turquoise"
        case .golden: return "Golden"
        case .softBlue: return "Soft Blue"
        case .lavender: return "Lavender"
        case .roseGray: return "Rose Gray"
        case .slate: return "Slate"
        case .icyBlue: return "Icy Blue"
        case .emerald: return "Emerald"
        case .trueRed: return "True Red"
        case .deepBlack: return "Black"
        default: return "Color"
        }
    }

    private func swiftUIColor(from color: ClosetColor) -> Color {
        Color(red: color.red, green: color.green, blue: color.blue)
    }

    /// Cream text over dark/saturated swatches, ink text over light ones — by relative luminance.
    private func textColor(for color: ClosetColor) -> Color {
        let luminance = 0.299 * color.red + 0.587 * color.green + 0.114 * color.blue
        return luminance > 0.6 ? Theme.Color.ink : Theme.Color.cream
    }
}
