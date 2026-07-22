import SwiftUI

struct TabBarShell: View {
    let closetViewModel: ClosetViewModel

    @State private var selectedTab: AppTab = .closet

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTab.check.title, image: AppTab.check.iconName, value: AppTab.check) {
                NavigationStack {
                    ComingSoonView(title: AppTab.check.title)
                }
            }
            Tab(AppTab.analysis.title, image: AppTab.analysis.iconName, value: AppTab.analysis) {
                NavigationStack {
                    ComingSoonView(title: AppTab.analysis.title)
                }
            }
            Tab(AppTab.closet.title, image: AppTab.closet.iconName, value: AppTab.closet) {
                NavigationStack {
                    ClosetView(viewModel: closetViewModel)
                }
            }
        }
        .tint(Theme.Color.ink)
    }
}
