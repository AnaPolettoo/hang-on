import Foundation
import Testing
import SwiftData
@testable import AcademyAI

struct PurchaseCheckTests {
    @Test func checkRoundTripsThroughSwiftData() throws {
        let container = try ModelContainer(for: PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)

        let check = PurchaseCheck(
            imageData: Data([0x01]),
            category: .tops,
            dominantColor: ClosetColor(red: 0.5, green: 0.4, blue: 0.3),
            matchesColorimetry: true,
            fillsGap: false,
            verdictText: "Combina com você, mas você já tem parecido.",
            decision: .comprou
        )
        context.insert(check)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<PurchaseCheck>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.category == .tops)
        #expect(fetched.first?.matchesColorimetry == true)
        #expect(fetched.first?.fillsGap == false)
        #expect(fetched.first?.decision == .comprou)
        #expect(fetched.first?.dominantColor.red == 0.5)
        #expect(fetched.first?.id == check.id)
    }

    @Test func matchesColorimetryAndFillsGapDefaultToNilWhenUnknown() throws {
        let container = try ModelContainer(for: PurchaseCheck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let check = PurchaseCheck(
            imageData: Data(), category: .other, dominantColor: .lime,
            matchesColorimetry: nil, fillsGap: nil,
            verdictText: "x", decision: .naoComprou
        )
        context.insert(check)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<PurchaseCheck>())
        #expect(fetched.first?.matchesColorimetry == nil)
        #expect(fetched.first?.fillsGap == nil)
    }
}
