import SwiftUI

/// Reached from `PaletteResultView`'s "Why these colors?" link. Read-only: shows
/// the explanation paragraph the Foundation Models already generated (no new
/// generation here) plus a plain list of the recommended colors. Presented as a
/// `.sheet`, so — like `ProfileView` elsewhere in this app — it relies on the
/// system's drag-to-dismiss instead of its own close button.
struct PaletteExplanationView: View {
    let viewModel: PaletteExplanationViewModel

    var body: some View {
        ZStack {
            Theme.Color.cream.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(viewModel.season.displayName)
                        .font(Theme.Font.largeTitle)
                        .foregroundStyle(Theme.Color.ink)
                        .padding(.top, 8)

                    Text(viewModel.explanation)
                        .font(Theme.Font.body)
                        .foregroundStyle(Theme.Color.inkMuted)

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(viewModel.recommended.enumerated()), id: \.offset) { _, color in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(swiftUIColor(from: color))
                                    .frame(width: 28, height: 28)
                                    .overlay(Circle().stroke(Theme.Color.ink.opacity(0.2), lineWidth: 1))
                                Text(SeasonPalette.displayName(for: color))
                                    .font(Theme.Font.body)
                                    .foregroundStyle(Theme.Color.ink)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
        }
    }

    private func swiftUIColor(from color: ClosetColor) -> Color {
        Color(red: color.red, green: color.green, blue: color.blue)
    }
}

#Preview {
    PaletteExplanationView(
        viewModel: PaletteExplanationViewModel(
            season: .warmAutumn,
            recommended: SeasonPalette.recommendedColors(for: .warmAutumn),
            explanation: "Warm Autumn reads rich and earthy — golden undertones in your skin, warm depth in your hair and eyes. Colors like rust and olive echo that warmth, while icy blues and stark black fight it and wash you out."
        )
    )
}
