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
            return try ModelContainer(for: UserColorimetryProfile.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}

private struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserColorimetryProfile]
    @State private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding || !profiles.isEmpty {
            ContentView()
        } else {
            OnboardingCoordinatorView(modelContext: modelContext, onCompleted: { hasCompletedOnboarding = true })
        }
    }
}
