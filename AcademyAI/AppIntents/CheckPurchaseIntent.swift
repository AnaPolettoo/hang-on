import AppIntents
import Foundation

extension Notification.Name {
    static let checkPurchaseIntentTriggered = Notification.Name("checkPurchaseIntentTriggered")
}

struct CheckPurchaseIntent: AppIntent {
    static var title: LocalizedStringResource = "Essa peça vale a pena comprar?"
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .checkPurchaseIntentTriggered, object: nil)
        return .result()
    }
}

struct AcademyAIShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CheckPurchaseIntent(),
            phrases: ["Essa peça vale a pena comprar? \(.applicationName)"],
            shortTitle: "Check a Piece",
            systemImageName: "camera.viewfinder"
        )
    }
}
