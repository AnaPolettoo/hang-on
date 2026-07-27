import AppIntents
import Foundation
import SwiftData

extension Notification.Name {
    static let checkPurchaseIntentTriggered = Notification.Name("checkPurchaseIntentTriggered")
}

enum ClosetIntentError: Error, CustomLocalizedStringResourceConvertible {
    case noColorimetryProfile
    case emptyCloset

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .noColorimetryProfile:
            return "You haven't found your colors yet. Open the app and take the colorimetry test first."
        case .emptyCloset:
            return "Your closet is empty. Add a few pieces and ask me again."
        }
    }
}

/// Opens the app on the Check tab with the camera ready. This one has to open
/// the app — the person is standing in a store pointing at a garment.
struct CheckPurchaseIntent: AppIntent {
    static var title: LocalizedStringResource = "Check if a piece is worth buying"
    static var description = IntentDescription(
        "Opens the camera so you can photograph a piece you're considering, then says whether it suits your palette and fills a real gap.",
        categoryName: "Buying"
    )
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .checkPurchaseIntentTriggered, object: nil)
        return .result()
    }
}

/// Answers in place — no app launch. That's what makes it usable as a step
/// inside a larger Shortcut, instead of only as a way to open the app.
struct MyPaletteIntent: AppIntent {
    static var title: LocalizedStringResource = "Get my color palette"
    static var description = IntentDescription(
        "Tells you your colorimetry subseason and the colors that suit you, without opening the app.",
        categoryName: "Colors"
    )
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let context = ModelContext(AppModelContainer.shared)
        guard let profile = try context.fetch(FetchDescriptor<UserColorimetryProfile>()).first else {
            throw ClosetIntentError.noColorimetryProfile
        }

        let season = profile.season.displayName
        let colors = profile.recommendedColors
            .map { ClothingColorSwatch.nearest(to: $0).displayName.lowercased() }
        let spoken = colors.isEmpty
            ? "You're a \(season)."
            : "You're a \(season). Your colors are \(Self.listPhrase(colors))."

        // The returned value is the subseason alone, so a Shortcut can branch on
        // it; the dialog is the part a person hears.
        return .result(value: season, dialog: IntentDialog(stringLiteral: spoken))
    }

    static func listPhrase(_ items: [String]) -> String {
        guard let last = items.last else { return "" }
        guard items.count > 1 else { return last }
        return items.dropLast().joined(separator: ", ") + " and " + last
    }
}

/// Also answers in place. Reuses `WardrobeAnalyzer`, the same pure logic the
/// Analysis tab reads from — "in your palette" is not defined twice.
struct WardrobeSummaryIntent: AppIntent {
    static var title: LocalizedStringResource = "Summarize my closet"
    static var description = IntentDescription(
        "Tells you how many pieces you have and how much of your closet sits in your palette, without opening the app.",
        categoryName: "Closet"
    )
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Int> & ProvidesDialog {
        let context = ModelContext(AppModelContainer.shared)
        let items = try context.fetch(FetchDescriptor<ClothingItem>())
        guard !items.isEmpty else { throw ClosetIntentError.emptyCloset }

        let pieces = items.count
        let noun = pieces == 1 ? "piece" : "pieces"

        // `nil` when nothing has been scored against a palette yet (colorimetry
        // not done) — say the count alone rather than inventing a percentage.
        guard let inPalette = WardrobeAnalyzer.percentInPalette(items: items) else {
            return .result(
                value: pieces,
                dialog: IntentDialog(stringLiteral: "You have \(pieces) \(noun) in your closet.")
            )
        }

        let percent = Int((inPalette * 100).rounded())
        return .result(
            value: pieces,
            dialog: IntentDialog(stringLiteral: "You have \(pieces) \(noun), and \(percent) percent of them are in your palette.")
        )
    }
}

struct AcademyAIShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        // Every phrase has to name the app, so each one is written to still sound
        // like something a person would say out loud with the name inside it.
        AppShortcut(
            intent: CheckPurchaseIntent(),
            phrases: [
                "Is this worth buying, \(.applicationName)?",
                "Should I buy this with \(.applicationName)?",
                "Check this piece with \(.applicationName)",
                "Ask \(.applicationName) if this is worth it",
                "Check a piece in \(.applicationName)"
            ],
            shortTitle: "Check a Piece",
            systemImageName: "camera.viewfinder"
        )
        AppShortcut(
            intent: MyPaletteIntent(),
            phrases: [
                "What's my palette in \(.applicationName)?",
                "What are my colors in \(.applicationName)?",
                "What season am I in \(.applicationName)?",
                "What colors suit me, \(.applicationName)?",
                "Tell me my \(.applicationName) palette"
            ],
            shortTitle: "My Palette",
            systemImageName: "paintpalette"
        )
        AppShortcut(
            intent: WardrobeSummaryIntent(),
            phrases: [
                "How's my closet in \(.applicationName)?",
                "Summarize my closet in \(.applicationName)",
                "How many pieces do I have in \(.applicationName)?",
                "What's in my \(.applicationName) closet?"
            ],
            shortTitle: "Closet Summary",
            systemImageName: "tshirt"
        )
    }
}
