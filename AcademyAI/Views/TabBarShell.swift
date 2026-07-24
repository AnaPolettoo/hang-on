import SwiftUI
import SwiftData

struct TabBarShell: View {
    let closetViewModel: ClosetViewModel
    let purchaseCheckViewModel: PurchaseCheckViewModel
    let analysisViewModel: AnalysisViewModel
    let profileViewModel: ProfileViewModel
    let modelContext: ModelContext

    @State private var selectedTab: AppTab = .closet

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTab.check.title, image: AppTab.check.iconName, value: AppTab.check) {
                NavigationStack {
                    PurchaseCheckView(viewModel: purchaseCheckViewModel)
                }
            }
            Tab(AppTab.analysis.title, image: AppTab.analysis.iconName, value: AppTab.analysis) {
                NavigationStack {
                    AnalysisView(viewModel: analysisViewModel)
                }
            }
            Tab(AppTab.closet.title, image: AppTab.closet.iconName, value: AppTab.closet) {
                NavigationStack {
                    ClosetView(viewModel: closetViewModel, profileViewModel: profileViewModel, modelContext: modelContext)
                }
            }
        }
        .tint(Theme.Color.accentBorder)
        .onReceive(NotificationCenter.default.publisher(for: .checkPurchaseIntentTriggered)) { _ in
            selectedTab = .check
            purchaseCheckViewModel.pendingAutoLaunchCamera = true
        }
    }
}
