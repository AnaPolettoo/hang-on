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
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Theme.Color.ink)
                            .frame(height: 2)
                            .offset(y: 4)
                    }

                Text("What should we call you?")
                    .font(Theme.Font.subheadline)
                    .foregroundStyle(Theme.Color.inkMuted)

                TextField("Your name", text: $viewModel.name)
                    .font(Theme.Font.title)
                    .foregroundStyle(Theme.Color.ink)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .background(Theme.Color.cream)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Theme.Color.ink, lineWidth: 1.5)
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
