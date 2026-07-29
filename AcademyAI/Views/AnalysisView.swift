// AcademyAI/Views/AnalysisView.swift
import SwiftUI
import UIKit
import SwiftData

struct AnalysisView: View {
    let viewModel: AnalysisViewModel

    private let horizontalPadding: CGFloat = 16
    private let cardCornerRadius: CGFloat = 18

    var body: some View {
        Group {
            if viewModel.items.isEmpty {
                emptyState
            } else {
                populatedState
            }
        }
        .navigationTitle("Wardrobe")
        .navigationBarTitleDisplayMode(.large)
        .background(Theme.Color.cream)
        .onAppear { viewModel.loadItems() }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            VStack(spacing: 12) {
                Text("Nothing to hang your hat on yet")
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
            VStack(alignment: .leading, spacing: 20) {
                statsRow
                categorySection
                if let insight = viewModel.gapInsight {
                    worthBuyingNextSection(insight)
                }
                if !viewModel.neutralPieces.isEmpty {
                    neutralPiecesSection
                }
                if !viewModel.offPaletteItems.isEmpty {
                    offPaletteSection
                }
                if !viewModel.donationCandidates.isEmpty {
                    considerDonatingSection
                }
            }
            .padding(.top, Theme.Layout.spacingXS)
            .padding(.bottom, 24)
        }
        .contentMargins(.horizontal, horizontalPadding, for: .scrollContent)
        .scrollIndicators(.hidden)
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(value: "\(viewModel.totalCount)", label: "pieces")
            statCard(
                value: viewModel.percentInPalette.map { "\(Int(($0 * 100).rounded()))%" } ?? "—",
                label: "in your palette"
            )
        }
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(Theme.Font.statNumber)
                .foregroundStyle(Theme.Color.ink)
            Text(label)
                .font(Theme.Font.micro)
                .foregroundStyle(Theme.Color.ink.opacity(0.6))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardBackground(cornerRadius: cardCornerRadius)
    }

    // MARK: - By Category

    private var categorySection: some View {
        let counts = viewModel.categoryCounts.filter { $0.category != .other }
        let maxCount = max(counts.map(\.count).max() ?? 0, 1)
        return VStack(alignment: .leading, spacing: 12) {
            Text("BY CATEGORY")
                .font(Theme.Font.micro)
                .tracking(0.5)
                .foregroundStyle(Theme.Color.ink.opacity(0.6))
            VStack(alignment: .leading, spacing: 12) {
                ForEach(counts, id: \.category) { entry in
                    categoryRow(entry, maxCount: maxCount)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardBackground(cornerRadius: cardCornerRadius)
        }
    }

    private func categoryRow(_ entry: WardrobeAnalyzer.CategoryCount, maxCount: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.category.pluralDisplayName.capitalized)
                    .font(Theme.Font.subheadline)
                    .foregroundStyle(Theme.Color.ink)
                Spacer()
                Text("\(entry.count)")
                    .font(Theme.Font.subheadline)
                    .foregroundStyle(Theme.Color.ink.opacity(0.6))
            }
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Theme.Color.ink.opacity(0.1))
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Theme.Color.ink)
                            .frame(width: geometry.size.width * CGFloat(entry.count) / CGFloat(maxCount))
                    }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Worth buying next

    private func worthBuyingNextSection(_ insight: WardrobeAnalyzer.GapInsight) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("WORTH BUYING NEXT")
                .font(Theme.Font.micro)
                .tracking(0.5)
                .foregroundStyle(Theme.Color.ink.opacity(0.6))
            Text("\(insight.gapCategory.pluralDisplayName.capitalized) are your gap")
                .font(Theme.Font.button)
                .foregroundStyle(Theme.Color.ink)
                .padding(.top, 4)
            Text("You have \(insight.leadingCount) \(insight.leadingCategory.pluralDisplayName) but only \(insight.gapCount) \(insight.gapCategory.pluralDisplayName). Time to balance your closet.")
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.Color.ink.opacity(0.6))
                .padding(.top, 8)
            if !viewModel.suggestedSwatches.isEmpty {
                HStack(spacing: 8) {
                    ForEach(viewModel.suggestedSwatches, id: \.self) { swatch in
                        Text("\(swatch.displayName) \(insight.gapCategory.displayNoun)")
                            .font(Theme.Font.micro)
                            .foregroundStyle(swatch.color.isDark ? Theme.Color.cream : Theme.Color.ink)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 3)
                            .background(swiftUIColor(swatch.color))
                            .overlay(Capsule().stroke(Theme.Color.ink.opacity(0.2), lineWidth: 1))
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 12)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardBackground(cornerRadius: cardCornerRadius)
    }

    // MARK: - Neutral pieces

    private var neutralPiecesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NEUTRAL PIECES · \(viewModel.neutralPieces.count)")
                .font(Theme.Font.micro)
                .tracking(0.5)
                .foregroundStyle(Theme.Color.ink.opacity(0.6))
            Text("Not in your palette, but neutrals pair with everything.")
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.Color.ink.opacity(0.6))
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(viewModel.neutralPieces) { item in
                    offPaletteTile(item)
                }
            }
        }
    }

    // MARK: - Off your palette

    private var offPaletteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("OFF YOUR PALETTE · \(viewModel.offPaletteItems.count)")
                .font(Theme.Font.micro)
                .tracking(0.5)
                .foregroundStyle(Theme.Color.ink.opacity(0.6))
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(viewModel.offPaletteItems) { item in
                    offPaletteTile(item)
                }
            }
        }
    }

    private func offPaletteTile(_ item: ClothingItem) -> some View {
        ZStack {
            Color.itemBackground
            if let uiImage = UIImage(data: item.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding(4)
            }
        }
        .aspectRatio(0.75, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Theme.Color.ink.opacity(0.18), lineWidth: 1)
        }
    }

    // MARK: - Consider donating

    private var considerDonatingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CONSIDER DONATING")
                .font(Theme.Font.micro)
                .tracking(0.5)
                .foregroundStyle(Theme.Color.ink.opacity(0.6))
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.donationCandidates, id: \.item.persistentModelID) { candidate in
                    donationCandidateRow(candidate)
                }
            }
        }
    }

    private func donationCandidateRow(_ candidate: DonationAdvisor.Candidate) -> some View {
        HStack(alignment: .top, spacing: 12) {
            offPaletteTile(candidate.item)
                .frame(width: 64, height: 85)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    if candidate.isForgotten {
                        donationCriterionChip("Forgotten")
                    }
                    if candidate.isOffPalette {
                        donationCriterionChip("Off palette")
                    }
                    if candidate.isDuplicate {
                        donationCriterionChip("Duplicate")
                    }
                }
                Text(viewModel.donationSuggestion(for: candidate.item) ?? "...")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.Color.ink.opacity(0.7))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardBackground(cornerRadius: cardCornerRadius)
        .task(id: candidate.item.persistentModelID) {
            guard viewModel.donationSuggestion(for: candidate.item) == nil else { return }
            await viewModel.loadDonationSuggestion(for: candidate)
        }
    }

    private func donationCriterionChip(_ label: String) -> some View {
        Text(label)
            .font(Theme.Font.micro)
            .foregroundStyle(Theme.Color.ink)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Theme.Color.accentBorder.opacity(0.25))
            .clipShape(Capsule())
    }

    private func swiftUIColor(_ color: ClosetColor) -> Color {
        Color(red: color.red, green: color.green, blue: color.blue)
    }
}

private extension View {
    /// The "grey/94" card treatment shared by every panel on this screen: item
    /// background fill, 2px ink border, matching corner radius.
    func cardBackground(cornerRadius: CGFloat) -> some View {
        self
            .background(Color.itemBackground)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Theme.Color.ink, lineWidth: 2)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

@MainActor
private func makePopulatedAnalysisPreview() -> some View {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, PurchaseCheck.self, configurations: configuration)
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
        name: "Ana Carolina", skinToneSample: .beige, eyeColorSample: .wine, hairColorSample: .wine,
        season: .warmAutumn, recommendedColors: [.lime, .wine, .beige], avoidColors: []
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
    let container = try! ModelContainer(for: ClothingItem.self, UserColorimetryProfile.self, PurchaseCheck.self, configurations: configuration)
    let viewModel = AnalysisViewModel(modelContext: container.mainContext)
    return NavigationStack { AnalysisView(viewModel: viewModel) }
        .modelContainer(container)
}
