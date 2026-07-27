import SwiftUI
import UIKit

struct AddClothingItemMenu: View {
    let viewModel: ClosetViewModel
    let onAdded: () -> Void

    @State private var showCamera = false
    @State private var showLibrary = false

    var body: some View {
        VStack(spacing: 8) {
            // A Menu instead of a confirmationDialog so Take Photo / Choose from
            // Library pop up anchored right at this button. The label reproduces
            // PrimaryButtonStyle's look by hand — a custom ButtonStyle isn't
            // guaranteed to apply to a Menu's trigger.
            Menu {
                Button("Take Photo") { showCamera = true }
                Button("Choose from Library") { showLibrary = true }
            } label: {
                Text("Add a Piece")
                    .font(Theme.Font.button)
                    .foregroundStyle(Theme.Color.cream)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Theme.Color.ink)
                    .clipShape(Capsule())
            }
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
        guard let cgImage = image.cgImage else {
            viewModel.errorMessage = "Couldn't process the photo. Try again."
            return
        }
        Task {
            let processed = await viewModel.processPhoto(cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation))
            // Low-confidence/failed identification still shouldn't block saving (REQ-2.2).
            let displayImage = processed.map { UIImage(cgImage: $0.image) } ?? image
            guard let imageData = displayImage.jpegData(compressionQuality: 0.85) else {
                viewModel.errorMessage = "Couldn't process the photo. Try again."
                return
            }
            let colorSwatch = processed.map { ClothingColorSwatch.nearest(to: $0.classification.dominantColor) } ?? .grey
            let category = processed?.classification.category ?? .other
            // No pattern flag here: this path saves without a review screen, and
            // the detector isn't reliable enough to set it unattended (see
            // AddPieceView). The piece is saved as unpatterned; the person can
            // still say otherwise when adding through the review flow.
            viewModel.saveItem(imageData: imageData, category: category, colorSwatch: colorSwatch)
            if viewModel.errorMessage == nil { onAdded() }
        }
    }
}
