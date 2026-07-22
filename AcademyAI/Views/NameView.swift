import SwiftUI

struct NameView: View {
    @Bindable var viewModel: NameViewModel
    let onContinue: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Nice to meet you")
                .font(.largeTitle)
            Text("What should we call you?")
                .foregroundStyle(.secondary)
            TextField("Ana Carolina", text: $viewModel.name)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Spacer()

            Button("Continue", action: onContinue)
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)

            Button("Skip for now", action: onSkip)
                .font(.footnote)
        }
        .padding()
    }
}

#Preview {
    NameView(viewModel: NameViewModel(), onContinue: {}, onSkip: {})
}
