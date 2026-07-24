// AcademyAI/Views/AnalysisView.swift
import SwiftUI
import UIKit
import SwiftData

struct AnalysisView: View {
    let viewModel: AnalysisViewModel

    private let horizontalPadding: CGFloat = 24

    var body: some View {
        ZStack {
            if viewModel.items.isEmpty {
                emptyState
            } else {
                populatedState
            }
        }
        .navigationTitle("Analysis")
        .navigationBarTitleDisplayMode(.automatic)
        .background(Theme.Color.cream)
        .onAppear { viewModel.loadItems() }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            VStack(spacing: 12) {
                Text("No stats yet")
                    .font(Theme.Font.sectionTitle)
                    .foregroundStyle(Theme.Color.ink)
                Text("Add pieces to your closet to see your wardrobe analysis")
                    .font(Theme.Font.subheadline)
                    .foregroundStyle(Theme.Color.ink.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var populatedState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                summarySection
                categorySection
                if viewModel.gapCategory != nil, !viewModel.suggestedSwatches.isEmpty {
                    worthBuyingNextSection
                }
                if !viewModel.offPaletteItems.isEmpty {
                    offPaletteSection
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .contentMargins(.horizontal, horizontalPadding, for: .scrollContent)
        .scrollIndicators(.hidden)
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(viewModel.totalCount) pieces catalogued")
                .font(Theme.Font.sectionTitle)
                .foregroundStyle(Theme.Color.ink)
            if let percentInPalette = viewModel.percentInPalette {
                Text("\(Int((percentInPalette * 100).rounded()))% in your palette")
                    .font(Theme.Font.subheadline)
                    .foregroundStyle(Theme.Color.ink.opacity(0.6))
            }
        }
    }

    private var categorySection: some View {
        let maxCount = max(viewModel.categoryCounts.map(\.count).max() ?? 0, 1)
        return VStack(alignment: .leading, spacing: 12) {
            Text("BY CATEGORY")
                .font(Theme.Font.subheadline)
                .foregroundStyle(Theme.Color.ink.opacity(0.55))
            VStack(alignment: .leading, spacing: 10) {
                ForEach(viewModel.categoryCounts, id: \.category) { entry in
                    HStack {
                        Text(entry.category.pluralDisplayName.capitalized)
                            .font(Theme.Font.body)
                            .foregroundStyle(Theme.Color.ink)
                        Spacer()
                        Text("\(entry.count)")
                            .font(Theme.Font.body)
                            .foregroundStyle(Theme.Color.ink.opacity(0.6))
                    }
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Theme.Color.ink.opacity(0.15))
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(Theme.Color.ink)
                                    .frame(width: geometry.size.width * CGFloat(entry.count) / CGFloat(maxCount))
                            }
                    }
                    .frame(height: 6)
                }
            }
        }
    }

    private var worthBuyingNextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("WORTH BUYING NEXT")
                .font(Theme.Font.subheadline)
                .foregroundStyle(Theme.Color.ink.opacity(0.55))
            if let gapCategory = viewModel.gapCategory {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(viewModel.suggestedSwatches, id: \.self) { swatch in
                        Text("\(swatch.displayName) \(gapCategory.displayNoun)")
                            .font(Theme.Font.body)
                            .foregroundStyle(Theme.Color.ink)
                    }
                }
            }
        }
    }

    private var offPaletteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("OFF YOUR PALETTE")
                .font(Theme.Font.subheadline)
                .foregroundStyle(Theme.Color.ink.opacity(0.55))
            ForEach(viewModel.offPaletteItems) { item in
                HStack(spacing: 12) {
                    ZStack {
                        Color.itemBackground
                        if let uiImage = UIImage(data: item.imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .padding(2)
                        }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    Text(item.category.displayNoun)
                        .font(Theme.Font.body)
                        .foregroundStyle(Theme.Color.ink)
                }
            }
        }
    }
}

@MainActor
private func makePopulatedAnalysisPreview() -> some View {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: configuration)
    let context = container.mainContext

    let placeholderImageData = UIImage(systemName: "tshirt.fill")?.pngData() ?? Data()
    let categories: [(ClothingCategory, ClosetColor, Bool?)] = [
        (.tops, .lime, true), (.tops, .wine, true), (.tops, .beige, false),
        (.outerwear, .lime, true), (.outerwear, .wine, true),
        (.shoes, .beige, false)
    ]
    for (category, color, matches) in categories {
        context.insert(ClothingItem(imageData: placeholderImageData, category: category, dominantColor: color, matchesColorimetry: matches))
    }
    context.insert(UserColorimetryProfile(
        name: nil, skinToneSample: .beige, eyeColorSample: .wine, hairColorSample: .wine,
        season: .autumn, recommendedColors: [.lime, .wine, .beige], avoidColors: []
    ))

    let viewModel = AnalysisViewModel(modelContext: context)
    return NavigationStack { AnalysisView(viewModel: viewModel) }
        .modelContainer(container)
}

#Preview("Populated Analysis") {
    makePopulatedAnalysisPreview()
}

#Preview("Empty Analysis") {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, configurations: configuration)
    let viewModel = AnalysisViewModel(modelContext: container.mainContext)
    return NavigationStack { AnalysisView(viewModel: viewModel) }
        .modelContainer(container)
}
