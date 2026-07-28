import SwiftUI

struct PaletteResultView: View {
    let viewModel: PaletteResultViewModel
    var ctaLabel: String = "Start Checking"
    let onStartChecking: () -> Void

    @State private var showExplanation = false

    var body: some View {
        ZStack {
            Theme.Color.cream.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(viewModel.season.displayName)
                        .font(Theme.Font.largeTitle)
                        .foregroundStyle(Theme.Color.ink)
                        .padding(.top, 8)

                    ForEach(Array(viewModel.recommended.enumerated()), id: \.offset) { _, color in
                        Text(SeasonPalette.displayName(for: color))
                            .font(Theme.Font.title)
                            .foregroundStyle(textColor(for: color))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(swiftUIColor(from: color))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                                    .stroke(Theme.Color.ink, lineWidth: 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius))
                    }

                    Button("Why these colors?") { showExplanation = true }
                        .font(Theme.Font.subheadline)
                        .foregroundStyle(Theme.Color.ink)
                        .underline()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)

                    Button(ctaLabel, action: onStartChecking)
                        .buttonStyle(.closetPrimary)
                        .padding(.top, 8)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showExplanation) {
            PaletteExplanationView(
                viewModel: PaletteExplanationViewModel(
                    season: viewModel.season,
                    recommended: viewModel.recommended,
                    explanation: viewModel.explanation
                )
            )
        }
    }

    private func swiftUIColor(from color: ClosetColor) -> Color {
        Color(red: color.red, green: color.green, blue: color.blue)
    }

    /// Cream text over dark/saturated swatches, ink text over light ones.
    private func textColor(for color: ClosetColor) -> Color {
        color.isDark ? Theme.Color.cream : Theme.Color.ink
    }
}

#Preview {
    PaletteResultView(
        viewModel: PaletteResultViewModel(
            season: .warmAutumn,
            recommended: SeasonPalette.recommendedColors(for: .warmAutumn),
            avoid: SeasonPalette.avoidColors(for: .warmAutumn),
            explanation: "Warm Autumn reads rich and earthy: golden undertones in your skin, warm depth in your hair and eyes. Colors like rust and olive echo that warmth, while icy blues and stark black fight it and wash you out."
        ),
        onStartChecking: {}
    )
}
