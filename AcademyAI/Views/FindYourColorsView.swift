import SwiftUI

struct FindYourColorsView: View {
    let viewModel: FindYourColorsViewModel
    let name: String?
    let onResult: () -> Void
    @State private var showCamera = false

    var body: some View {
        ZStack {
            Theme.Color.cream.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Find Your Colors")
                    .font(Theme.Font.largeTitle)
                    .foregroundStyle(Theme.Color.ink)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Theme.Color.ink)
                            .frame(height: 2)
                            .offset(y: 4)
                    }

                Text("Natural light, no filters — we just need to see you.")
                    .font(Theme.Font.subheadline)
                    .foregroundStyle(Theme.Color.inkMuted)
                    .multilineTextAlignment(.center)

                Spacer()

                ZStack {
                    Ellipse()
                        .stroke(Theme.Color.ink, lineWidth: 2)
                        .frame(width: 260, height: 340)

                    if viewModel.isProcessing {
                        ProgressView("Analisando...")
                            .tint(Theme.Color.ink)
                            .foregroundStyle(Theme.Color.ink)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(Theme.Font.subheadline)
                            .foregroundStyle(Theme.Color.ink)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    } else {
                        VStack(spacing: 6) {
                            Text("Align your face here")
                                .font(Theme.Font.subheadline)
                                .foregroundStyle(Theme.Color.ink)
                            Text("Tap to capture")
                                .font(Theme.Font.caption)
                                .foregroundStyle(Theme.Color.inkMuted)
                        }
                    }
                }

                Spacer()

                Button("Take Selfie") { showCamera = true }
                    .buttonStyle(.closetPrimary)
                    .padding(.horizontal)
                    .disabled(viewModel.isProcessing)
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraCaptureView(
                onCapture: { image in
                    showCamera = false
                    guard let cgImage = image.cgImage else {
                        viewModel.errorMessage = "Não foi possível processar a foto. Tenta de novo."
                        return
                    }
                    Task {
                        await viewModel.processSelfie(cgImage, name: name)
                        if viewModel.result != nil { onResult() }
                    }
                },
                onCancel: { showCamera = false }
            )
            .ignoresSafeArea()
        }
    }
}
