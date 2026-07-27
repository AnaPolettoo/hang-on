import Testing
import SwiftData
@testable import AcademyAI

struct UserColorimetryProfileTests {
    @Test func profileRoundTripsThroughSwiftData() throws {
        let container = try ModelContainer(
            for: UserColorimetryProfile.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)

        let profile = UserColorimetryProfile(
            name: "Ana",
            skinToneSample: ClosetColor(red: 0.7, green: 0.5, blue: 0.4),
            eyeColorSample: ClosetColor(red: 0.3, green: 0.2, blue: 0.1),
            hairColorSample: ClosetColor(red: 0.15, green: 0.08, blue: 0.05),
            season: .warmAutumn,
            recommendedColors: SeasonPalette.recommendedColors(for: .warmAutumn),
            avoidColors: SeasonPalette.avoidColors(for: .warmAutumn)
        )
        context.insert(profile)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<UserColorimetryProfile>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Ana")
        #expect(fetched.first?.season == .warmAutumn)
        #expect(fetched.first?.recommendedColors.count == 8)
    }
}
