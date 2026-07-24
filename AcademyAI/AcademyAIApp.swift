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
            return try ModelContainer(for: UserColorimetryProfile.self, ClothingItem.self, PurchaseCheck.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [
            .font: UIFont(name: "PatrickHand-Regular", size: 30) ?? .systemFont(ofSize: 30, weight: .bold),
            .foregroundColor: UIColor(Theme.Color.ink)
        ]
        appearance.titleTextAttributes = [
            .font: UIFont(name: "PatrickHand-Regular", size: 17) ?? .systemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor(Theme.Color.ink)
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            // The whole design (Theme.swift) is a fixed light palette with no dark
            // variants — without this, system chrome (tab bar material, nav bar)
            // follows the device's Dark Mode schedule while our hardcoded colors
            // don't, causing mismatched/invisible text once the system switches.
            RootView(modelContext: modelContainer.mainContext)
                .preferredColorScheme(.light)
        }
        .modelContainer(modelContainer)
    }
}

private struct RootView: View {
    // Persisted (not derived from `UserColorimetryProfile` existing) because a profile
    // is saved mid-onboarding, right after the selfie — well before the flow finishes
    // (palette result, optional catalog prompt). Gating on profile existence made
    // RootView swap away from OnboardingCoordinatorView the instant that save happened,
    // skipping the rest of onboarding.
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var closetViewModel: ClosetViewModel
    @State private var purchaseCheckViewModel: PurchaseCheckViewModel
    @State private var analysisViewModel: AnalysisViewModel
    @State private var profileViewModel: ProfileViewModel
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        _closetViewModel = State(initialValue: ClosetViewModel(modelContext: modelContext))
        _purchaseCheckViewModel = State(initialValue: PurchaseCheckViewModel(modelContext: modelContext))
        _analysisViewModel = State(initialValue: AnalysisViewModel(modelContext: modelContext))
        _profileViewModel = State(initialValue: ProfileViewModel(modelContext: modelContext))
    }

    var body: some View {
        if hasCompletedOnboarding {
            TabBarShell(closetViewModel: closetViewModel, purchaseCheckViewModel: purchaseCheckViewModel, analysisViewModel: analysisViewModel, profileViewModel: profileViewModel, modelContext: modelContext)
                .onAppear { closetViewModel.loadItems() }
        } else {
            OnboardingCoordinatorView(modelContext: modelContext, onCompleted: {
                hasCompletedOnboarding = true
                closetViewModel.loadItems()
            })
        }
    }
}
