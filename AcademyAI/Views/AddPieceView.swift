import SwiftUI
import UIKit
import SwiftData

struct AddPieceView: View {
    let viewModel: ClosetViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showCamera = false
    @State private var showLibrary = false
    
    @State private var reviewImage: UIImage?
    @State private var reviewImageData: Data?
    @State private var selectedColorSwatch: ClothingColorSwatch?
    @State private var selectedCategory: ClothingCategory?
    @State private var isPatterned = false
    @State private var sessionAddedItems: [ClothingItem] = []
    @State private var pendingConfirmImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let reviewImage {
                        reviewCard(reviewImage)
                    } else {
                        HStack{
                            Spacer()
                            Text("For pieces you already own. Add a photo and we'll guess the color and category, you can always fix it before saving.")
                                .font(Theme.Font.caption)
                                .foregroundStyle(Theme.Color.inkMuted)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        if !sessionAddedItems.isEmpty {
                            sessionAddedRow
                        }
                        addPhotoCard
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(Theme.Font.caption)
                            .foregroundStyle(Theme.Color.inkMuted)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    
                    if reviewImage != nil {
                        PieceAttributesEditor(
                            selectedColorSwatch: $selectedColorSwatch,
                            selectedCategory: $selectedCategory,
                            isPatterned: $isPatterned
                        )
                    }
                }
                .padding()
                .padding(.bottom, 90)
            }
            
            doneBar
        }
        .background(Theme.Color.cream.ignoresSafeArea())
        .navigationTitle("Add a Piece")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
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
                    // Unlike the camera (which already shows its own native
                    // Retake/Use Photo confirmation before calling onCapture),
                    // PHPickerViewController hands back a photo the instant it's
                    // tapped — so this app-level confirm step is what gives the
                    // library path the same "confirm before it's used" pause.
                    pendingConfirmImage = image
                },
                onCancel: { showLibrary = false }
            )
        }
        .fullScreenCover(isPresented: Binding(
            get: { pendingConfirmImage != nil },
            set: { isPresented in
                if !isPresented { pendingConfirmImage = nil }
            }
        )) {
            if let pendingConfirmImage {
                confirmPhotoView(pendingConfirmImage)
            }
        }
    }

    private func confirmPhotoView(_ image: UIImage) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 12) {
                Button("Use Photo") {
                    self.pendingConfirmImage = nil
                    Task { await process(image) }
                }
                .buttonStyle(.closetPrimary)

                Button("Choose Again") {
                    self.pendingConfirmImage = nil
                    showLibrary = true
                }
                .buttonStyle(.closetDashed)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Theme.Color.cream.ignoresSafeArea())
    }
    
    // A Menu instead of a confirmationDialog so Take Photo / Choose from Library pop
    // up anchored right at this card, not as an unrelated sheet from the bottom.
    private var addPhotoCard: some View {
        Menu {
            Button { showCamera = true } label: {
                Label("Take Photo", systemImage: "camera.fill")
            }
            .tint(Theme.Color.accentBorder)
            Button { showLibrary = true } label: {
                Label("Choose from Library", systemImage: "photo.on.rectangle.fill")
            }
            .tint(Theme.Color.accentBorder)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Theme.Color.ink)
                
                RoundedRectangle(cornerRadius: 40)
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
        .disabled(viewModel.isProcessing)
    }
    
    private var sessionAddedRow: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(sessionAddedItems) { item in
                    sessionThumbnail(item)
                }
            }
        }
    }
    
    private func sessionThumbnail(_ item: ClothingItem) -> some View {
        ZStack {
            Theme.Color.cream
            
            if let uiImage = UIImage(data: item.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding(4)
            }
        }
        .frame(width: 64, height: 85.3)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Theme.Color.ink.opacity(0.18), lineWidth: 1)
        }
    }
    
    private func reviewCard(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color(hex: "F6F2EA"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.Color.ink.opacity(0.2), lineWidth: 1)
            )
    }
    
    private var doneBar: some View {
        Button("Done") {
            // Review state: save this piece and loop back to the ready state
            // (the same screen, ready for another). Ready state: nothing to save —
            // Done just leaves, like the back chevron.
            if reviewImage != nil {
                addThisPiece()
            } else {
                dismiss()
            }
        }
        .buttonStyle(.closetPrimary)
        .padding(.horizontal, 24)
        .padding(.vertical, 13)
        .background(Theme.Color.cream)
    }
    
    private func process(_ image: UIImage) async {
        guard let cgImage = image.cgImage else {
            viewModel.errorMessage = "Couldn't process the photo. Try again."
            return
        }
        let processed = await viewModel.processPhoto(cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation))

        // Low-confidence/failed identification still shouldn't block saving (REQ-2.2):
        // fall back to "other"/an approximate color. When processed is nil (classify
        // failed), keep the original photo so the person can still review and fix it.
        let displayImage = processed.map { UIImage(cgImage: $0.image) } ?? image
        reviewImage = displayImage
        reviewImageData = displayImage.pngData()
        selectedColorSwatch = processed.map { ClothingColorSwatch.nearest(to: $0.classification.dominantColor) } ?? .grey
        // Deliberately not pre-filled from the classification: the histogram-based
        // detector fired on every solid garment we measured (a real photo's folds
        // and shading spread one color across many bins), so auto-marking would
        // mean unchecking this on nearly every piece. The person sets it.
        isPatterned = false
        selectedCategory = processed.map { PieceAttributesEditor.reviewableCategories.contains($0.classification.category) ? $0.classification.category : .other } ?? .other
    }
    
    private func addThisPiece() {
        guard let imageData = reviewImageData, let colorSwatch = selectedColorSwatch, let category = selectedCategory else { return }
        viewModel.saveItem(
            imageData: imageData,
            category: category,
            colorSwatch: colorSwatch,
            isPatterned: isPatterned
        )
        guard viewModel.errorMessage == nil else { return }
        if let savedItem = viewModel.items.first {
            sessionAddedItems.append(savedItem)
        }
        reviewImage = nil
        reviewImageData = nil
        selectedColorSwatch = nil
        selectedCategory = nil
        isPatterned = false
    }
}
