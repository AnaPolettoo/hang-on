import SwiftUI

struct SplashView: View {
    @State private var viewModel = SplashViewModel()
    let onFinished: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tshirt")
                .font(.system(size: 48))
            Text("Closet")
                .font(.largeTitle)
            Text("check it before you buy it")
                .font(.subheadline)
                .foregroundStyle(.secondary)
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
