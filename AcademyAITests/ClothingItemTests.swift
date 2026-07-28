import Foundation
import Testing
import SwiftData
@testable import AcademyAI

struct ClothingItemTests {
    @Test func itemRoundTripsThroughSwiftData() throws {
        let container = try ModelContainer(for: ClothingItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)

        let item = ClothingItem(
            imageData: Data([0x01, 0x02]),
            category: .tops,
            dominantColor: ClosetColor(red: 0.5, green: 0.4, blue: 0.3),
            matchesColorimetry: true
        )
        context.insert(item)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ClothingItem>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.category == .tops)
        #expect(fetched.first?.matchesColorimetry == true)
        #expect(fetched.first?.dominantColor.red == 0.5)
        #expect(fetched.first?.acquiredViaPurchaseCheck == false)
    }

    @Test func matchesColorimetryDefaultsToNilWhenUnknown() throws {
        let container = try ModelContainer(for: ClothingItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let item = ClothingItem(imageData: Data(), category: .other, dominantColor: .lime, matchesColorimetry: nil)
        context.insert(item)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ClothingItem>())
        #expect(fetched.first?.matchesColorimetry == nil)
    }

    @Test func linkedPurchaseCheckIdDefaultsToNilAndRoundTrips() throws {
        let container = try ModelContainer(for: ClothingItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)

        let unlinked = ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: nil)
        context.insert(unlinked)

        let checkId = UUID()
        let linked = ClothingItem(imageData: Data(), category: .shoes, dominantColor: .wine, matchesColorimetry: nil, acquiredViaPurchaseCheck: true, linkedPurchaseCheckId: checkId)
        context.insert(linked)
        try context.save()

        #expect(unlinked.linkedPurchaseCheckId == nil)
        #expect(linked.linkedPurchaseCheckId == checkId)
    }

    @Test func wearTrackingDefaultsToNeverLogged() throws {
        let container = try ModelContainer(for: ClothingItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let item = ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: nil)
        context.insert(item)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ClothingItem>())
        #expect(fetched.first?.lastWornDate == nil)
        #expect(fetched.first?.wearCount == 0)
    }

    @Test func wearTrackingRoundTripsThroughSwiftData() throws {
        let container = try ModelContainer(for: ClothingItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let item = ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: nil)
        item.lastWornDate = now
        item.wearCount = 5
        context.insert(item)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ClothingItem>())
        #expect(fetched.first?.lastWornDate == now)
        #expect(fetched.first?.wearCount == 5)
    }
}
