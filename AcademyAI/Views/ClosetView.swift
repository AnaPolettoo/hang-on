// AcademyAI/Views/ClosetView.swift
import SwiftUI
import UIKit

struct ClosetView: View {
    let viewModel: ClosetViewModel

    @State private var showAddPiece = false

    private let thumbnailColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    private var groupedItems: [(category: ClothingCategory, items: [ClothingItem])] {
        let order: [ClothingCategory] = [.tops, .bottoms, .outerwear, .shoes, .other]
        return order.compactMap { category in
            let items = viewModel.items.filter { $0.category == category }
            return items.isEmpty ? nil : (category, items)
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Theme.Color.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if viewModel.items.isEmpty {
                    emptyState
                } else {
                    populatedState
                }
            }

            if !viewModel.items.isEmpty {
                Button {
                    showAddPiece = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Theme.Color.cream)
                        .frame(width: 56, height: 56)
                        .background(Theme.Color.ink)
                        .clipShape(Circle())
                }
                .padding()
            }
        }
        // Native `.large` title display mode + a custom UINavigationBarAppearance
        // font silently failed to render any text on a real device (confirmed via
        // screenshot — AddPieceView's `.inline` title with the same appearance DID
        // render correctly, isolating the bug to large titles specifically). Rather
        // than depend on that unreliable native path, this screen draws its own
        // title/avatar row — guaranteed to render since it's plain SwiftUI, and it
        // also matches Figma's single-row title+avatar layout more closely than a
        // native large title (whose trailing toolbar item sits in a separate compact
        // bar above the large title) ever could.
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showAddPiece) {
            AddPieceView(viewModel: viewModel, onDone: { showAddPiece = false })
        }
    }

    private var header: some View {
        HStack {
            Text("My Closet")
                .font(Theme.Font.largeTitle)
                .foregroundStyle(Theme.Color.ink)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Theme.Color.ink)
                        .frame(height: 2)
                        .offset(y: 4)
                }

            Spacer()

            if let profileName = viewModel.profileName, let initials = Self.initials(from: profileName) {
                Text(initials)
                    .font(Theme.Font.subheadline)
                    .foregroundStyle(Theme.Color.ink)
                    .frame(width: 44, height: 44)
                    .background(Theme.Color.accentBorder)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Theme.Color.ink, lineWidth: 2))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image("ClosetEmptyHanger")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 54, height: 54)
                .foregroundStyle(Theme.Color.ink)

            VStack(spacing: 12) {
                Text("Your closet is empty")
                    .font(Theme.Font.sectionTitle)
                    .foregroundStyle(Theme.Color.ink)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Theme.Color.ink)
                            .frame(height: 2)
                            .offset(y: 3)
                    }

                Text("It fills itself as you go — every piece you buy after a check lands here on its own. Or add a few now.")
                    .font(Theme.Font.subheadline)
                    .foregroundStyle(Theme.Color.ink.opacity(0.6))
                    .multilineTextAlignment(.center)
            }

            Button("+ Add a piece") { showAddPiece = true }
                .buttonStyle(.closetPrimary)

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private var populatedState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(groupedItems, id: \.category) { group in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(group.category.rawValue.capitalized) · \(group.items.count)")
                            .font(Theme.Font.subheadline)
                            .foregroundStyle(Theme.Color.ink)

                        LazyVGrid(columns: thumbnailColumns, spacing: 8) {
                            ForEach(group.items) { item in
                                itemTile(item)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
    }

    private func itemTile(_ item: ClothingItem) -> some View {
        Group {
            if let uiImage = UIImage(data: item.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Theme.Color.ink.opacity(0.1)
            }
        }
        .aspectRatio(0.75, contentMode: .fill)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.Color.ink.opacity(0.15), lineWidth: 1)
        )
    }

    private static func initials(from name: String) -> String? {
        let letters = name.split(separator: " ").compactMap { $0.first }
        guard !letters.isEmpty else { return nil }
        return String(letters.prefix(2)).uppercased()
    }
}
