import SwiftUI

struct ComingSoonView: View {
    let title: String

    var body: some View {
        Text("Coming in a future update.")
            .font(Theme.Font.subheadline)
            .foregroundStyle(Theme.Color.inkMuted)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.Color.cream.ignoresSafeArea())
            .navigationTitle(title)
    }
}

#Preview {
    NavigationStack {
        ComingSoonView(title: "Check")
    }
}
