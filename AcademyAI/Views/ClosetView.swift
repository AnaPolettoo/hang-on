// AcademyAI/Views/ClosetView.swift
import SwiftUI
import UIKit

struct ClosetView: View {
    let viewModel: ClosetViewModel

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Theme.Color.cream.ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Your Closet")
                    .font(Theme.Font.largeTitle)
                    .foregroundStyle(Theme.Color.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if viewModel.items.isEmpty {
                    Spacer()
                    Text("Your closet fills up on its own — check a piece before you buy it and it lands here.")
                        .font(Theme.Font.body)
                        .foregroundStyle(Theme.Color.inkMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.items) { item in
                                itemTile(item)
                            }
                        }
                    }
                }

                AddClothingItemMenu(viewModel: viewModel, onAdded: {})
            }
            .padding()
        }
    }

    private func itemTile(_ item: ClothingItem) -> some View {
        VStack(spacing: 4) {
            if let uiImage = UIImage(data: item.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                            .stroke(Theme.Color.ink, lineWidth: 1.5)
                    )
            }
            Text(item.category.rawValue.capitalized)
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.Color.inkMuted)
        }
    }
}
