import SwiftUI
import UIKit

struct AddPieceView: View {
    let viewModel: ClosetViewModel
    let onDone: () -> Void

    @State private var showActionSheet = false
    @State private var showCamera = false
    @State private var showLibrary = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("For pieces you already own. Add a photo and we'll guess its color and type — fix anything that's off, then save.")
                    .font(Theme.Font.subheadline)
                    .foregroundStyle(Theme.Color.inkMuted)

                addPhotoCard

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(Theme.Font.caption)
                        .foregroundStyle(Theme.Color.inkMuted)
                        .multilineTextAlignment(.center)
                }

                Button("Done", action: onDone)
                    .buttonStyle(.closetDashed)
            }
            .padding()
        }
        .background(Theme.Color.cream.ignoresSafeArea())
        .navigationTitle("Add a Piece")
        .navigationBarTitleDisplayMode(.inline)
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

    private var addPhotoCard: some View {
        Button {
            showActionSheet = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Theme.Color.ink)

                RoundedRectangle(cornerRadius: 20)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                    .foregroundStyle(Theme.Color.ink.opacity(0.5))

                VStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Theme.Color.accentBorder)

                    VStack(spacing: 4) {
                        Text("Tap to add a photo")
                            .font(Theme.Font.body)
                            .foregroundStyle(Color(hex: "E5E1D8"))
                        Text("Camera or library")
                            .font(Theme.Font.caption)
                            .foregroundStyle(Color(hex: "E3DED4"))
                    }
                }

                ViewfinderCorners()
                    .padding(16)

                if viewModel.isProcessing {
                    Color.black.opacity(0.3)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    ProgressView()
                        .tint(Theme.Color.cream)
                }
            }
            .frame(height: 224)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isProcessing)
    }

    private func process(_ image: UIImage) {
        guard let cgImage = image.cgImage, let imageData = image.jpegData(compressionQuality: 0.85) else {
            viewModel.errorMessage = "Não foi possível processar a foto. Tenta de novo."
            return
        }
        Task {
            await viewModel.addItem(image: cgImage, imageData: imageData)
        }
    }
}
