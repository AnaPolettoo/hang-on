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

                Text("Natural light, no filters. We just need to see you.")
                    .font(Theme.Font.subheadline)
                    .foregroundStyle(Theme.Color.inkMuted)
                    .multilineTextAlignment(.center)

                Spacer()

                ZStack {
                    Ellipse()
                        .stroke(
                            style: viewModel.isProcessing || viewModel.errorMessage != nil
                                ? StrokeStyle(lineWidth: 3)
                                : StrokeStyle(lineWidth: 3, dash: [6])
                        )
                        .foregroundStyle(Theme.Color.ink.opacity(0.4))
                        .frame(width: 260, height: 340)

                    if viewModel.isProcessing {
                        ProgressView("Analyzing...")
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
                                .foregroundStyle(Theme.Color.ink.opacity(0.7))
                            Text("Tap to capture")
                                .font(Theme.Font.caption)
                                .foregroundStyle(Theme.Color.ink.opacity(0.45))
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
                cameraDevice: .front,
                onCapture: { image in
                    showCamera = false
                    guard let cgImage = image.cgImage else {
                        viewModel.errorMessage = String(localized: "Couldn't process the photo. Try again.")
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
