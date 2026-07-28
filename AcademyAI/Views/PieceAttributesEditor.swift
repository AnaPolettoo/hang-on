import SwiftUI

/// The color, category, and "Patterned" pickers shared between AddPieceView's
/// review screen and EditPieceView — extracted so the two screens can't drift
/// out of sync (e.g. a swatch added to one but not the other, REQ-E.3).
struct PieceAttributesEditor: View {
    @Binding var selectedColorSwatch: ClothingColorSwatch?
    @Binding var selectedCategory: ClothingCategory?
    @Binding var isPatterned: Bool

    static let reviewableCategories: [ClothingCategory] = [.tops, .outerwear, .dresses, .bottoms, .shoes, .other]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            colorSection
            categorySection
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color")
                .font(Theme.Font.body)
                .foregroundStyle(Theme.Color.ink)

            FlowLayout(spacing: 8, rowSpacing: 8) {
                ForEach(ClothingColorSwatch.allCases, id: \.self) { swatch in
                    swatchPill(swatch)
                }
                patternedPill
            }
        }
    }

    private var patternedPill: some View {
        Button {
            isPatterned.toggle()
        } label: {
            Text("Patterned")
                .font(Theme.Font.caption)
                .foregroundStyle(isPatterned ? Theme.Color.cream : Theme.Color.ink)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(isPatterned ? Theme.Color.ink : Color.clear)
                .overlay(
                    Capsule().stroke(
                        isPatterned ? Theme.Color.ink : Theme.Color.ink.opacity(0.3),
                        lineWidth: isPatterned ? 2 : 1
                    )
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isPatterned ? [.isSelected] : [])
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
                    .fixedSize()
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

            FlowLayout(spacing: 8, rowSpacing: 8) {
                ForEach(Self.reviewableCategories, id: \.self) { category in
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
                .fixedSize()
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

    private func swiftUIColor(_ color: ClosetColor) -> Color {
        Color(red: color.red, green: color.green, blue: color.blue)
    }
}

#Preview {
    @Previewable @State var swatch: ClothingColorSwatch? = .yellow
    @Previewable @State var category: ClothingCategory? = .tops
    @Previewable @State var isPatterned = false

    return PieceAttributesEditor(
        selectedColorSwatch: $swatch,
        selectedCategory: $category,
        isPatterned: $isPatterned
    )
    .padding()
    .background(Theme.Color.cream)
}
