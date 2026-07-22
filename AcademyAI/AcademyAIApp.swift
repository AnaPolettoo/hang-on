//
//  AcademyAIApp.swift
//  AcademyAI
//
//  Created by Ana Poletto on 17/07/26.
//

import SwiftUI
import SwiftData

@main
struct AcademyAIApp: App {
    let modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: UserColorimetryProfile.self, ClothingItem.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView(modelContext: modelContainer.mainContext)
        }
        .modelContainer(modelContainer)
    }
}

private struct RootView: View {
    @Query private var profiles: [UserColorimetryProfile]
    @State private var hasCompletedOnboarding = false
    @State private var closetViewModel: ClosetViewModel
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        _closetViewModel = State(initialValue: ClosetViewModel(modelContext: modelContext))
    }

    var body: some View {
        if hasCompletedOnboarding || !profiles.isEmpty {
            ClosetView(viewModel: closetViewModel)
                .onAppear { closetViewModel.loadItems() }
        } else {
            OnboardingCoordinatorView(modelContext: modelContext, onCompleted: {
                hasCompletedOnboarding = true
                closetViewModel.loadItems()
            })
        }
    }
}
