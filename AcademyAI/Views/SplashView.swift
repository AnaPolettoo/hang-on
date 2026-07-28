import SwiftUI

struct SplashView: View {
    @State private var viewModel = SplashViewModel()
    let onFinished: () -> Void

    var body: some View {
        ZStack {
            Theme.Color.cream.ignoresSafeArea()

            VStack(spacing: 12) {
                Image("SplashHanger")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 78)

                Text("Hang On")
                    .font(Theme.Font.display)
                    .foregroundStyle(Theme.Color.ink)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Theme.Color.ink)
                            .frame(height: 3)
                            .offset(y: 4)
                    }

                Text("Is it your color?")
                    .font(Theme.Font.subheadline)
                    .foregroundStyle(Theme.Color.ink.opacity(0.55))
            }
        }
        .onAppear { viewModel.startTimer() }
        .onChange(of: viewModel.isReadyToAdvance) { _, isReady in
            if isReady { onFinished() }
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
