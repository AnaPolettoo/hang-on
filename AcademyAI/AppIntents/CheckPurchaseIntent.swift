import AppIntents
import Foundation
import SwiftData

extension Notification.Name {
    static let checkPurchaseIntentTriggered = Notification.Name("checkPurchaseIntentTriggered")
}

enum ClosetIntentError: Error, Equatable, CustomLocalizedStringResourceConvertible {
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

/// What the intents actually compute, split out from the `AppIntent` shells so
/// it can be exercised against an in-memory store — an `AppIntent` is built by
/// the system and can't be handed a test container.
enum IntentAnswers {
    struct Palette: Equatable {
        /// Returned as the Shortcut's value, so a shortcut can branch on it.
        let season: String
        /// What the person hears.
        let spoken: String
    }

    static func palette(context: ModelContext) throws -> Palette {
        guard let profile = try context.fetch(FetchDescriptor<UserColorimetryProfile>()).first else {
            throw ClosetIntentError.noColorimetryProfile
        }
        let season = profile.season.displayName
        let colors = profile.recommendedColors
            .map { ClothingColorSwatch.nearest(to: $0).displayName.lowercased() }
        return Palette(
            season: season,
            spoken: colors.isEmpty
                ? "You're a \(season)."
                : "You're a \(season). Your colors are \(listPhrase(colors))."
        )
    }

    struct ClosetSummary: Equatable {
        let pieces: Int
        let spoken: String
    }

    static func closetSummary(context: ModelContext) throws -> ClosetSummary {
        let items = try context.fetch(FetchDescriptor<ClothingItem>())
        guard !items.isEmpty else { throw ClosetIntentError.emptyCloset }

        let pieces = items.count
        let noun = pieces == 1 ? "piece" : "pieces"

        // `nil` when nothing has been scored against a palette yet (colorimetry
        // not done) — say the count alone rather than inventing a percentage.
        guard let inPalette = WardrobeAnalyzer.percentInPalette(items: items) else {
            return ClosetSummary(pieces: pieces, spoken: "You have \(pieces) \(noun) in your closet.")
        }
        let percent = Int((inPalette * 100).rounded())
        return ClosetSummary(
            pieces: pieces,
            spoken: "You have \(pieces) \(noun), and \(percent) percent of them are in your palette."
        )
    }

    static func listPhrase(_ items: [String]) -> String {
        guard let last = items.last else { return "" }
        guard items.count > 1 else { return last }
        return items.dropLast().joined(separator: ", ") + " and " + last
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
        let answer = try IntentAnswers.palette(context: ModelContext(AppModelContainer.shared))
        return .result(value: answer.season, dialog: IntentDialog(stringLiteral: answer.spoken))
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
        let answer = try IntentAnswers.closetSummary(context: ModelContext(AppModelContainer.shared))
        return .result(value: answer.pieces, dialog: IntentDialog(stringLiteral: answer.spoken))
    }
}

struct AcademyAIShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        // Every phrase has to name the app, so each one is written to still sound
        // like something a person would say out loud with the name inside it.
        // Phrases stay in English here — that's the project's only declared locale
        // (see `knownRegions` in the .pbxproj). Portuguese variants live in
        // Localizable.xcstrings as pt-BR translations of these exact strings;
        // mixing raw Portuguese text into this array doesn't make Siri understand
        // Portuguese, it just files more English-locale phrases Siri never matches
        // against a pt-BR request.
        AppShortcut(
            intent: CheckPurchaseIntent(),
            phrases: [
                "Is this worth buying, \(.applicationName)?",
                "Should I buy this with \(.applicationName)?",
                "Check this piece with \(.applicationName)",
                "Ask \(.applicationName) if this is worth it",
                "Check a piece in \(.applicationName)",
                // pun: "deserve to hang" = worth keeping, playing on the app's name
                "\(.applicationName), does this piece deserve to hang in my closet?"
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
                "Tell me my \(.applicationName) palette",
                // pun: "hang best on me" = suit me well, playing on the app's name
                "\(.applicationName), which colors hang best on me?"
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
                "What's in my \(.applicationName) closet?",
                // pun: "what's hanging" = what's in the closet, playing on the app's name
                "\(.applicationName), catch me up on what's hanging in my closet"
            ],
            shortTitle: "Closet Summary",
            systemImageName: "tshirt"
        )
    }

    // Closest system tile color to the app's dusty-rose accent (Theme.Color.accentBorder,
    // #D38492) — Shortcuts/Spotlight tiles only accept this fixed palette, not arbitrary hex.
    static var shortcutTileColor: ShortcutTileColor { .pink }
}
