import SwiftUI
import SwiftData
import UIKit

/// Corrects a catalogued piece's category, color, or "Patterned" flag — never
/// its photo (REQ-E.2/out of scope: refetching means delete-and-re-add).
struct EditPieceView: View {
    let item: ClothingItem
    let viewModel: ClosetViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var selectedColorSwatch: ClothingColorSwatch?
    @State private var selectedCategory: ClothingCategory?
    @State private var isPatterned: Bool

    init(item: ClothingItem, viewModel: ClosetViewModel) {
        self.item = item
        self.viewModel = viewModel
        _selectedColorSwatch = State(initialValue: ClothingColorSwatch.nearest(to: item.dominantColor))
        _selectedCategory = State(initialValue: item.category)
        _isPatterned = State(initialValue: item.isPatterned)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    photoCard

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(Theme.Font.caption)
                            .foregroundStyle(Theme.Color.inkMuted)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }

                    PieceAttributesEditor(
                        selectedColorSwatch: $selectedColorSwatch,
                        selectedCategory: $selectedCategory,
                        isPatterned: $isPatterned
                    )
                }
                .padding()
                .padding(.bottom, 90)
            }

            saveBar
        }
        .background(Theme.Color.cream.ignoresSafeArea())
        .navigationTitle("Edit Piece")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }

    private var photoCard: some View {
        Group {
            if let uiImage = UIImage(data: item.imageData) {
                Image(uiImage: uiImage)
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
        }
    }

    private var saveBar: some View {
        Button("Save") {
            guard let colorSwatch = selectedColorSwatch, let category = selectedCategory else { return }
            viewModel.updateItem(item, category: category, colorSwatch: colorSwatch, isPatterned: isPatterned)
            if viewModel.errorMessage == nil {
                dismiss()
            }
        }
        .buttonStyle(.closetPrimary)
        .padding(.horizontal, 24)
        .padding(.vertical, 13)
        .background(Theme.Color.cream)
    }
}

@MainActor
private func makeEditPiecePreview() -> some View {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, PurchaseCheck.self, configurations: configuration)
    let context = container.mainContext

    let placeholderImageData = UIImage(systemName: "tshirt.fill")?.pngData() ?? Data()
    let item = ClothingItem(imageData: placeholderImageData, category: .tops, dominantColor: .lime, matchesColorimetry: true)
    context.insert(item)

    let viewModel = ClosetViewModel(modelContext: context)

    return NavigationStack {
        EditPieceView(item: item, viewModel: viewModel)
    }
    .modelContainer(container)
}

#Preview("Edit Piece") {
    makeEditPiecePreview()
}
