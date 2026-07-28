import SwiftUI

struct SplashView: View {
    @State private var viewModel = SplashViewModel()
    let onFinished: () -> Void

    var body: some View {
        ZStack {
            Theme.Color.cream.ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: "hanger")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(Theme.Color.accentBorder)

                Text("WorthWear")
                    .font(Theme.Font.display)
                    .foregroundStyle(Theme.Color.ink)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Theme.Color.accentBorder)
                            .frame(height: 2)
                            .offset(y: 4)
                    }

                Text("check it before you buy it")
                    .font(Theme.Font.subheadline)
                    .foregroundStyle(Theme.Color.inkMuted)
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
