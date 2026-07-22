import SwiftUI

struct FindYourColorsView: View {
    let viewModel: FindYourColorsViewModel
    let name: String?
    let onResult: () -> Void
    @State private var showCamera = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Find Your Colors")
                .font(.largeTitle)
            Text("Natural light, no filters — we just need to see you.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            if viewModel.isProcessing {
                ProgressView("Analisando...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button("Take Selfie") { showCamera = true }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .disabled(viewModel.isProcessing)
        }
        .padding()
        .fullScreenCover(isPresented: $showCamera) {
            CameraCaptureView(
                onCapture: { image in
                    showCamera = false
                    guard let cgImage = image.cgImage else { return }
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
