import SwiftUI
import UIKit

struct PurchaseCheckView: View {
    let viewModel: PurchaseCheckViewModel

    @State private var showActionSheet = false
    @State private var showCamera = false
    @State private var showLibrary = false
    @State private var pendingCropImage: UIImage?
    @State private var pendingVerdict: PendingVerdict?

    struct PendingVerdict {
        let displayImage: UIImage
        let imageData: Data
        let category: ClothingCategory
        let dominantColor: ClosetColor
        let matchesColorimetry: Bool?
        let fillsGap: Bool?
        let motivo: String
        let recomendacao: String
    }

    var body: some View {
        VStack {
            if let pendingVerdict {
                verdictCard(pendingVerdict)
            } else {
                idleCard
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.Color.inkMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Color.cream.ignoresSafeArea())
        .navigationTitle("Check")
        .confirmationDialog("Check a Piece", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("Take Photo") { showCamera = true }
            Button("Choose from Library") { showLibrary = true }
            Button("Cancel", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraCaptureView(
                cameraDevice: .rear,
                onCapture: { image in
                    showCamera = false
                    Task { await process(image) }
                },
                onCancel: { showCamera = false }
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showLibrary) {
            PhotoLibraryPickerView(
                onPick: { image in
                    showLibrary = false
                    pendingCropImage = uprightImage(from: image)
                },
                onCancel: { showLibrary = false }
            )
        }
        .fullScreenCover(isPresented: Binding(
            get: { pendingCropImage != nil },
            set: { isPresented in if !isPresented { pendingCropImage = nil } }
        )) {
            if let pendingCropImage {
                NavigationStack {
                    CropPhotoView(
                        image: pendingCropImage,
                        onCrop: { cropped in
                            self.pendingCropImage = nil
                            Task { await process(cropped) }
                        },
                        onCancel: { self.pendingCropImage = nil }
                    )
                }
            }
        }
        .onChange(of: viewModel.pendingAutoLaunchCamera) { _, shouldLaunch in
            guard shouldLaunch else { return }
            showCamera = true
            viewModel.pendingAutoLaunchCamera = false
        }
        .onAppear {
            guard viewModel.pendingAutoLaunchCamera else { return }
            showCamera = true
            viewModel.pendingAutoLaunchCamera = false
        }
    }

    private var idleCard: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Fotografe uma peça que está cogitando comprar e a gente diz na hora se ela combina com você.")
                .font(Theme.Font.body)
                .foregroundStyle(Theme.Color.inkMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Check a Piece") { showActionSheet = true }
                .buttonStyle(.closetPrimary)
                .padding(.horizontal, 24)
                .disabled(viewModel.isProcessing)

            if viewModel.isProcessing {
                ProgressView().tint(Theme.Color.ink)
            }
            Spacer()
        }
    }

    private func verdictCard(_ verdict: PendingVerdict) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image(uiImage: verdict.displayImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .background(Color(hex: "F6F2EA"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 8) {
                    Text(verdict.motivo)
                        .font(Theme.Font.body)
                        .foregroundStyle(Theme.Color.ink)
                    Text(verdict.recomendacao)
                        .font(Theme.Font.body)
                        .foregroundStyle(Theme.Color.ink)
                }

                HStack(spacing: 12) {
                    Button("Não comprei") { recordDecision(.naoComprou, verdict: verdict) }
                        .buttonStyle(.closetDashed)
                    Button("Comprei") { recordDecision(.comprou, verdict: verdict) }
                        .buttonStyle(.closetPrimary)
                }
            }
            .padding()
        }
    }

    private func uprightImage(from image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let upright = ImageOrientation.upright(cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation))
        return UIImage(cgImage: upright)
    }

    private func process(_ image: UIImage) async {
        guard let cgImage = image.cgImage else {
            viewModel.errorMessage = "Não foi possível processar a foto. Tenta de novo."
            return
        }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let processed = await viewModel.checkPiece(cgImage, orientation: orientation) else { return }

        let displayImage = UIImage(cgImage: processed.image)
        guard let imageData = displayImage.jpegData(compressionQuality: 0.85) else {
            viewModel.errorMessage = "Não foi possível processar a foto. Tenta de novo."
            return
        }

        pendingVerdict = PendingVerdict(
            displayImage: displayImage,
            imageData: imageData,
            category: processed.classification.category,
            dominantColor: processed.classification.dominantColor,
            matchesColorimetry: processed.matchesColorimetry,
            fillsGap: processed.fillsGap,
            motivo: processed.motivo,
            recomendacao: processed.recomendacao
        )
    }

    private func recordDecision(_ decision: PurchaseDecision, verdict: PendingVerdict) {
        viewModel.recordDecision(
            imageData: verdict.imageData,
            category: verdict.category,
            dominantColor: verdict.dominantColor,
            matchesColorimetry: verdict.matchesColorimetry,
            fillsGap: verdict.fillsGap,
            verdictText: "\(verdict.motivo)\n\n\(verdict.recomendacao)",
            decision: decision
        )
        pendingVerdict = nil
    }
}
