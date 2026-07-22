import SwiftUI
import UIKit

struct AddPieceView: View {
    let viewModel: ClosetViewModel
    let onDone: () -> Void

    @State private var showActionSheet = false
    @State private var showCamera = false
    @State private var showLibrary = false

    @State private var reviewImage: UIImage?
    @State private var reviewImageData: Data?
    @State private var selectedColorSwatch: ClothingColorSwatch?
    @State private var selectedCategory: ClothingCategory?

    private let colorColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    private let reviewableCategories: [ClothingCategory] = [.tops, .outerwear, .bottoms, .shoes]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("For pieces you already own. Add a photo and we'll guess its color and type — fix anything that's off, then save.")
                        .font(Theme.Font.caption)
                        .foregroundStyle(Theme.Color.inkMuted)

                    if let reviewImage {
                        reviewCard(reviewImage)
                    } else {
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
                        detectedLabel
                        colorSection
                        categorySection
                        addThisPieceButton
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
                    Task { await process(image) }
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

    private var detectedLabel: some View {
        HStack(spacing: 6) {
            Text("✦")
            Text("WE DETECTED — TAP TO FIX")
                .tracking(0.3)
        }
        .font(Theme.Font.caption)
        .foregroundStyle(Theme.Color.ink.opacity(0.5))
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color")
                .font(Theme.Font.body)
                .foregroundStyle(Theme.Color.ink)

            LazyVGrid(columns: colorColumns, spacing: 8) {
                ForEach(ClothingColorSwatch.allCases, id: \.self) { swatch in
                    swatchPill(swatch)
                }
            }
        }
    }

    private func swatchPill(_ swatch: ClothingColorSwatch) -> some View {
        let isSelected = selectedColorSwatch == swatch
        return Button {
            selectedColorSwatch = swatch
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(swiftUIColor(swatch.color))
                    .frame(width: 18, height: 18)
                    .overlay(Circle().stroke(Theme.Color.ink.opacity(0.2), lineWidth: 1))
                Text(swatch.displayName)
                    .font(Theme.Font.caption)
            }
            .foregroundStyle(isSelected ? Theme.Color.cream : Theme.Color.ink)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(isSelected ? Theme.Color.ink : Color.clear)
            .overlay(
                Capsule().stroke(isSelected ? Theme.Color.ink : Theme.Color.ink.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(Theme.Font.body)
                .foregroundStyle(Theme.Color.ink)

            HStack(spacing: 8) {
                ForEach(reviewableCategories, id: \.self) { category in
                    categoryPill(category)
                }
            }
        }
    }

    private func categoryPill(_ category: ClothingCategory) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            selectedCategory = category
        } label: {
            Text(category.rawValue.capitalized)
                .font(Theme.Font.subheadline)
                .foregroundStyle(isSelected ? Theme.Color.cream : Theme.Color.ink)
                .padding(.vertical, 8)
                .padding(.horizontal, 18)
                .background(isSelected ? Theme.Color.ink : Color.clear)
                .overlay(
                    Capsule().stroke(isSelected ? Theme.Color.ink : Theme.Color.ink.opacity(0.3), lineWidth: 2)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var addThisPieceButton: some View {
        HStack {
            Spacer()
            Button("+ Add this piece") {
                addThisPiece()
            }
            .buttonStyle(.closetAccent)
            Spacer()
        }
    }

    private var doneBar: some View {
        Button("Done", action: onDone)
            .buttonStyle(.closetPrimary)
            .padding(.horizontal, 24)
            .padding(.vertical, 13)
            .background(Theme.Color.cream)
    }

    private func swiftUIColor(_ color: ClosetColor) -> Color {
        Color(red: color.red, green: color.green, blue: color.blue)
    }

    private func process(_ image: UIImage) async {
        guard let cgImage = image.cgImage else {
            viewModel.errorMessage = "Não foi possível processar a foto. Tenta de novo."
            return
        }
        guard let classification = await viewModel.classify(image: cgImage) else { return }

        reviewImage = image
        reviewImageData = image.jpegData(compressionQuality: 0.85)
        selectedColorSwatch = ClothingColorSwatch.nearest(to: classification.dominantColor)
        selectedCategory = reviewableCategories.contains(classification.category) ? classification.category : .tops
    }

    private func addThisPiece() {
        guard let imageData = reviewImageData, let colorSwatch = selectedColorSwatch, let category = selectedCategory else { return }
        viewModel.saveItem(imageData: imageData, category: category, colorSwatch: colorSwatch)
        guard viewModel.errorMessage == nil else { return }
        reviewImage = nil
        reviewImageData = nil
        selectedColorSwatch = nil
        selectedCategory = nil
    }
}
