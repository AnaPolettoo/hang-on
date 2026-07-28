import SwiftUI

struct NameView: View {
    @Bindable var viewModel: NameViewModel
    let onContinue: () -> Void
    let onSkip: () -> Void

    var body: some View {
        ZStack {
            Theme.Color.cream.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("Nice to meet you")
                    .font(Theme.Font.largeTitle)
                    .foregroundStyle(Theme.Color.ink)

                Text("What should we call you?")
                    .font(Theme.Font.subheadline)
                    .foregroundStyle(Theme.Color.inkMuted)

                TextField("Your Name", text: $viewModel.name)
                    .font(Theme.Font.sectionTitle)
                    .foregroundStyle(Theme.Color.ink)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .background(Theme.Color.cream)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(
                            style: viewModel.name.isEmpty
                                ? StrokeStyle(lineWidth: 2, dash: [4])
                                : StrokeStyle(lineWidth: 2)
                        )
                        .foregroundStyle(viewModel.name.isEmpty ? Theme.Color.ink.opacity(0.4) : Theme.Color.ink)
                    )
                    .padding(.horizontal)

                Spacer()

                Button("Continue", action: onContinue)
                    .buttonStyle(.closetPrimary)
                    .padding(.horizontal)

                Button("Skip for now", action: onSkip)
                    .font(Theme.Font.subheadline)
                    .foregroundStyle(Theme.Color.inkMuted)
                    .padding(.bottom, 8)
            }
            .padding()
        }
    }
}

#Preview {
    NameView(viewModel: NameViewModel(), onContinue: {}, onSkip: {})
}
