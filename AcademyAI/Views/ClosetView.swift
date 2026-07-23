// AcademyAI/Views/ClosetView.swift

import SwiftUI
import UIKit
import SwiftData

struct ClosetView: View {
    let viewModel: ClosetViewModel

    @State private var showAddPiece = false

    private let horizontalPadding: CGFloat = 24
    private let gridSpacing: CGFloat = 8

    private var thumbnailColumns: [GridItem] {
        Array(
            repeating: GridItem(
                .flexible(),
                spacing: gridSpacing
            ),
            count: 4
        )
    }

    private var groupedItems: [
        (category: ClothingCategory, items: [ClothingItem])
    ] {
        let order: [ClothingCategory] = [
            .tops,
            .outerwear,
            .bottoms,
            .shoes,
            .other
        ]

        return order.compactMap { category in
            let items = viewModel.items.filter {
                $0.category == category
            }

            return items.isEmpty
                ? nil
                : (category, items)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            if viewModel.items.isEmpty {
                emptyState
            } else {
                populatedState
            }
        }
        .background(Theme.Color.cream.ignoresSafeArea())
        .overlay(alignment: .bottomTrailing) {
            if !viewModel.items.isEmpty {
                addPieceFloatingButton
            }
        }
        // Native `.large` title reliably goes blank on a real device once the
        // closet has items and the populated ScrollView is on screen — confirmed
        // twice now, across two different body structures (a prior commit had
        // already diagnosed and fixed this exact combination before this file was
        // touched again this session). A hand-drawn header sidesteps the native
        // rendering bug entirely instead of chasing another structural variant.
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showAddPiece) {
            AddPieceView(viewModel: viewModel)
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

            profileButton
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    private var addPieceFloatingButton: some View {
        Button {
            showAddPiece = true
        } label: {
            Image(systemName: "plus")
                .font(
                    .system(
                        size: 24,
                        weight: .medium
                    )
                )
                .foregroundStyle(Theme.Color.cream)
                .frame(width: 64, height: 64)
                .background(Theme.Color.ink)
                .clipShape(Circle())
                .shadow(
                    color: Theme.Color.ink.opacity(0.18),
                    radius: 10,
                    y: 5
                )
        }
        .buttonStyle(.plain)
        .padding(.trailing, 24)
        .padding(.bottom, 24)
        .accessibilityLabel("Add a piece")
    }

    @ViewBuilder
    private var profileButton: some View {
        if let profileName = viewModel.profileName,
           let initials = Self.initials(from: profileName) {
            Button {
                // Abrir perfil futuramente
            } label: {
                Text(initials)
                    .font(Theme.Font.subheadline)
                    .foregroundStyle(Theme.Color.ink)
                    .frame(width: 44, height: 44)
                    .background(Theme.Color.accentBorder)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Profile")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            VStack(spacing: 4) {
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

                    Text("It fills itself as you go")
                        .font(Theme.Font.subheadline)
                        .foregroundStyle(
                            Theme.Color.ink.opacity(0.6)
                        )
                        .multilineTextAlignment(.center)
                }
            }

            Button("+ Add a piece") {
                showAddPiece = true
            }
            .buttonStyle(.closetPrimary)

            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var populatedState: some View {
        ScrollView {
            LazyVStack(
                alignment: .leading,
                spacing: 30
            ) {
                ForEach(
                    groupedItems,
                    id: \.category
                ) { group in
                    categorySection(group)
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 120)
        }
        .contentMargins(
            .horizontal,
            horizontalPadding,
            for: .scrollContent
        )
        .scrollIndicators(.hidden)
    }

    private func categorySection(
        _ group: (
            category: ClothingCategory,
            items: [ClothingItem]
        )
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(
                "\(group.category.rawValue.uppercased()) · \(group.items.count)"
            )
            .font(Theme.Font.subheadline)
            .foregroundStyle(
                Theme.Color.ink.opacity(0.55)
            )

            LazyVGrid(
                columns: thumbnailColumns,
                alignment: .leading,
                spacing: gridSpacing
            ) {
                ForEach(group.items) { item in
                    itemTile(item)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func itemTile(
        _ item: ClothingItem
    ) -> some View {
        ZStack {
            Theme.Color.cream

            if let uiImage = UIImage(data: item.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding(6)
            } else {
                Theme.Color.ink
                    .opacity(0.06)
            }
        }
        .aspectRatio(0.75, contentMode: .fit)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
            )
            .stroke(
                Theme.Color.ink.opacity(0.18),
                lineWidth: 1
            )
        }
    }

    private static func initials(
        from name: String
    ) -> String? {
        let letters = name
            .split(separator: " ")
            .compactMap(\.first)

        guard !letters.isEmpty else {
            return nil
        }

        return String(letters.prefix(2))
            .uppercased()
    }
}

#Preview("Empty Closet") {
    let configuration = ModelConfiguration(
        isStoredInMemoryOnly: true
    )

    let container = try! ModelContainer(
        for: ClothingItem.self,
        configurations: configuration
    )

    let viewModel = ClosetViewModel(
        modelContext: container.mainContext
    )

    ClosetView(viewModel: viewModel)
        .modelContainer(container)
}
