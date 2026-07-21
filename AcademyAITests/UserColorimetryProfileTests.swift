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
            skinToneSample: ClothingColor(red: 0.7, green: 0.5, blue: 0.4),
            eyeColorSample: ClothingColor(red: 0.3, green: 0.2, blue: 0.1),
            hairColorSample: ClothingColor(red: 0.15, green: 0.08, blue: 0.05),
            season: .autumn,
            recommendedColors: SeasonPalette.recommendedColors(for: .autumn),
            avoidColors: SeasonPalette.avoidColors(for: .autumn)
        )
        context.insert(profile)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<UserColorimetryProfile>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Ana")
        #expect(fetched.first?.season == .autumn)
        #expect(fetched.first?.recommendedColors.count == 4)
    }
}
