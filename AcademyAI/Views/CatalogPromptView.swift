import SwiftUI

struct CatalogPromptView: View {
    let viewModel: ClosetViewModel
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Theme.Color.cream.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("Start Your Closet")
                    .font(Theme.Font.largeTitle)
                    .foregroundStyle(Theme.Color.ink)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Theme.Color.ink)
                            .frame(height: 2)
                            .offset(y: 4)
                    }

                Text("Add a piece now, or skip. Your closet fills up on its own as you check pieces before buying.")
                    .font(Theme.Font.subheadline)
                    .foregroundStyle(Theme.Color.inkMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer()

                AddClothingItemMenu(viewModel: viewModel, onAdded: onContinue)
                    .padding(.horizontal)

                Button("Skip for now", action: onContinue)
                    .font(Theme.Font.subheadline)
                    .foregroundStyle(Theme.Color.inkMuted)
                    .padding(.bottom, 8)
            }
            .padding()
        }
    }
}
