import SwiftUI
import UIKit

struct AddClothingItemMenu: View {
    let viewModel: ClosetViewModel
    let onAdded: () -> Void

    @State private var showActionSheet = false
    @State private var showCamera = false
    @State private var showLibrary = false

    var body: some View {
        VStack(spacing: 8) {
            Button("Add a Piece") { showActionSheet = true }
                .buttonStyle(.closetPrimary)
                .disabled(viewModel.isProcessing)

            if viewModel.isProcessing {
                ProgressView()
                    .tint(Theme.Color.ink)
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.Color.inkMuted)
                    .multilineTextAlignment(.center)
            }
        }
        .confirmationDialog("Add a Piece", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("Take Photo") { showCamera = true }
            Button("Choose from Library") { showLibrary = true }
            Button("Cancel", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraCaptureView(
                cameraDevice: .rear,
                onCapture: { image in
                    showCamera = false
                    process(image)
                },
                onCancel: { showCamera = false }
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showLibrary) {
            PhotoLibraryPickerView(
                onPick: { image in
                    showLibrary = false
                    process(image)
                },
                onCancel: { showLibrary = false }
            )
        }
    }

    private func process(_ image: UIImage) {
        guard let cgImage = image.cgImage, let imageData = image.jpegData(compressionQuality: 0.85) else {
            viewModel.errorMessage = "Não foi possível processar a foto. Tenta de novo."
            return
        }
        Task {
            await viewModel.addItem(image: cgImage, imageData: imageData)
            if viewModel.errorMessage == nil { onAdded() }
        }
    }
}
