//
//  ContentView.swift
//  AcademyAI
//
//  Created by Ana Poletto on 17/07/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var profiles: [UserColorimetryProfile]

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal")
                .font(.largeTitle)
            if let profile = profiles.first {
                Text("Onboarding completo — perfil: \(profile.season.rawValue)")
            } else {
                Text("Onboarding completo")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
