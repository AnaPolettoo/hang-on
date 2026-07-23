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
        ZStack {
            if viewModel.items.isEmpty {
                emptyState
            } else {
                populatedState
            }
        }
        .navigationTitle("My Closet")
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            if !viewModel.items.isEmpty{
                ToolbarItem(placement: .primaryAction) {
                    addPieceButton
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                profileButton
            }
        }
        .navigationDestination(isPresented: $showAddPiece) {
            AddPieceView(viewModel: viewModel)
        }
        .background(.backgroundCustom)
    }
    
    private var addPieceButton: some View {
        Button {
            showAddPiece = true
        } label: {
            Image(systemName: "plus")
                .foregroundStyle(Theme.Color.cream)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.Color.ink)
        .accessibilityLabel("Add a piece")
    }
    
    private var profileButton: some View {
        Button {
            // Abrir perfil futuramente
        } label: {
            Image(systemName: "person.fill")
                .foregroundStyle(Theme.Color.ink)
        }
        .buttonStyle(.borderedProminent)
        .tint(.pinkCustom)
        .accessibilityLabel("Profile")
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
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
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
            .padding(.bottom, 24)
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
        VStack(alignment: .leading, spacing: 8) {
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
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }
    
    private func itemTile(
        _ item: ClothingItem
    ) -> some View {
        ZStack {
            Color.itemBackground
            
            if let uiImage = UIImage(data: item.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding(4)
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
}

@MainActor
private func makePopulatedClosetPreview() -> some View {
    let configuration = ModelConfiguration(
        isStoredInMemoryOnly: true
    )
    
    let container = try! ModelContainer(
        for: ClothingItem.self,
        configurations: configuration
    )
    
    let context = container.mainContext
    
    let placeholderImageData = UIImage(
        systemName: "tshirt.fill"
    )?.pngData() ?? Data()
    
    let categories: [ClothingCategory] = [
        .tops,
        .tops,
        .tops,
        .tops,
        .tops,
        .outerwear,
        .outerwear,
        .bottoms,
        .bottoms,
        .bottoms,
        .shoes,
        .shoes,
        .other
    ]
    
    for category in categories {
        let item = ClothingItem(
            imageData: placeholderImageData, category: category,
            dominantColor: .coral,
            matchesColorimetry: true
        )
        
        context.insert(item)
    }
    
    let viewModel = ClosetViewModel(
        modelContext: context
    )
    
    return NavigationStack {
        ClosetView(viewModel: viewModel)
    }
    .modelContainer(container)
}

#Preview("Populated Closet") {
    makePopulatedClosetPreview()
    
}
