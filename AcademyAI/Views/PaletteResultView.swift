import SwiftUI

struct PaletteResultView: View {
    let viewModel: PaletteResultViewModel
    let onStartChecking: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(seasonTitle)
                .font(.largeTitle)

            ForEach(Array(viewModel.recommended.enumerated()), id: \.offset) { _, color in
                Text(colorName(for: color))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(swiftUIColor(from: color))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Text(viewModel.explanation)
                .foregroundStyle(.secondary)

            Spacer()

            Button("Start Checking", action: onStartChecking)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
        }
        .padding()
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
        case .lime: return "Lime"
        case .wine: return "Wine"
        case .beige: return "Beige"
        case .mauve: return "Mauve"
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
}
