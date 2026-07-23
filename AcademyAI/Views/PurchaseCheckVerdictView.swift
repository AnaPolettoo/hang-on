import SwiftUI

struct PurchaseCheckVerdictView: View {
    let displayImage: UIImage
    let itemTitle: String
    let colorSwatch: ClothingColorSwatch
    let category: ClothingCategory
    let matchesColorimetry: Bool?
    let fillsGap: Bool?
    let similarItemImages: [UIImage]
    let similarItemsTotalCount: Int
    let motivo: String
    let recomendacao: String
    let onPass: () -> Void
    let onBuy: () -> Void

    private var recommendation: PurchaseRecommendation {
        PurchaseRecommendation.evaluate(matchesColorimetry: matchesColorimetry, fillsGap: fillsGap)
    }

    private var bullets: [String] {
        var items: [String] = []
        if matchesColorimetry == false {
            items.append("Off your palette")
        } else if matchesColorimetry == true {
            items.append("Matches your palette")
        }
        if fillsGap == false, similarItemsTotalCount > 0 {
            items.append("\(similarItemsTotalCount) similar \(category.pluralDisplayName) already in your closet")
        } else if fillsGap == true {
            items.append("Fills a gap in your closet")
        }
        return items
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                pieceCard
                recommendationCard
                honestTakeCard
                if !similarItemImages.isEmpty {
                    similarItemsSection
                }
                buttons
            }
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .background(Theme.Color.cream.ignoresSafeArea())
        .navigationTitle("The Verdict")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var pieceCard: some View {
        HStack(spacing: 12) {
            Image(uiImage: displayImage)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(itemTitle)
                    .font(Theme.Font.title)
                    .foregroundStyle(Theme.Color.ink)
                HStack(spacing: 8) {
                    badgePill(colorSwatch.displayName, background: swiftUIColor(colorSwatch.color))
                    badgePill(category.displayNoun, background: Theme.Color.accentYellow)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .background(Color(hex: "F6F2EA"))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.Color.ink, lineWidth: 2))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 24)
    }

    private func badgePill(_ text: String, background: Color) -> some View {
        Text(text)
            .font(Theme.Font.caption)
            .foregroundStyle(Theme.Color.ink)
            .padding(.horizontal, 13)
            .padding(.vertical, 3)
            .background(background)
            .overlay(Capsule().stroke(Theme.Color.ink.opacity(0.2), lineWidth: 1))
            .clipShape(Capsule())
    }

    private var recommendationCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: recommendation.symbolName)
                    .font(.system(size: 36))
                    .foregroundStyle(Theme.Color.accentBorder)
                VStack(alignment: .leading, spacing: 2) {
                    Text(recommendation.title)
                        .font(Theme.Font.title)
                        .foregroundStyle(Theme.Color.ink)
                    Text(recommendation.subtitle)
                        .font(Theme.Font.caption)
                        .foregroundStyle(Theme.Color.inkMuted)
                }
            }

            if !bullets.isEmpty {
                Divider().background(Theme.Color.ink.opacity(0.12))
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(bullets, id: \.self) { bullet in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Theme.Color.ink.opacity(0.55))
                                .frame(width: 5, height: 5)
                            Text(bullet)
                                .font(Theme.Font.subheadline)
                                .foregroundStyle(Theme.Color.ink.opacity(0.8))
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 18)
        .background(Color(hex: "F6F2EA"))
        .overlay(RoundedRectangle(cornerRadius: 26).stroke(Theme.Color.ink, lineWidth: 2))
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .padding(.horizontal, 24)
    }

    private var honestTakeCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("HONEST TAKE")
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.Color.accentBorder)
                .tracking(1)
            Text("\(motivo) \(recomendacao)")
                .font(Theme.Font.subheadline)
                .foregroundStyle(Theme.Color.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 22)
        .padding(.vertical, 18)
        .background(Color(hex: "F6F2EA"))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.Color.ink, lineWidth: 2))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 24)
    }

    private var similarItemsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(similarItemsTotalCount) \(category.pluralDisplayName.uppercased()) ALREADY IN YOUR CLOSET")
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.Color.ink.opacity(0.5))
                .tracking(0.5)

            HStack(spacing: 8) {
                ForEach(Array(similarItemImages.prefix(3).enumerated()), id: \.offset) { _, image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 68, height: 84)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.Color.ink.opacity(0.2), lineWidth: 1))
                }
                let remaining = similarItemsTotalCount - min(3, similarItemImages.count)
                if remaining > 0 {
                    Text("+\(remaining)")
                        .font(Theme.Font.caption)
                        .foregroundStyle(Theme.Color.ink.opacity(0.4))
                        .frame(width: 68, height: 84)
                        .background(Color(hex: "F6F2EA"))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.Color.ink.opacity(0.15), lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private var buttons: some View {
        VStack(spacing: 12) {
            Button("Pass", action: onPass)
                .buttonStyle(.closetPrimary)
            Button("Buy it anyway", action: onBuy)
                .buttonStyle(.closetOutline)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    private func swiftUIColor(_ color: ClosetColor) -> Color {
        Color(red: color.red, green: color.green, blue: color.blue)
    }
}
