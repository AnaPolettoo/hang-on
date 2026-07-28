import Foundation
import Testing
@testable import AcademyAI

struct WearTrackerTests {
    @Test func incrementsWhenNeverLoggedBefore() {
        #expect(WearTracker.shouldIncrementCount(lastWorn: nil, now: .now) == true)
    }

    @Test func doesNotIncrementWhenLoggedEarlierTheSameDay() {
        let calendar = Calendar.current
        let now = calendar.date(from: DateComponents(year: 2026, month: 7, day: 28, hour: 20, minute: 0))!
        let earlierSameDay = calendar.date(from: DateComponents(year: 2026, month: 7, day: 28, hour: 8, minute: 0))!
        #expect(WearTracker.shouldIncrementCount(lastWorn: earlierSameDay, now: now) == false)
    }

    @Test func incrementsWhenLoggedOnADifferentDay() {
        let calendar = Calendar.current
        let now = calendar.date(from: DateComponents(year: 2026, month: 7, day: 28, hour: 8, minute: 0))!
        let yesterday = calendar.date(from: DateComponents(year: 2026, month: 7, day: 27, hour: 20, minute: 0))!
        #expect(WearTracker.shouldIncrementCount(lastWorn: yesterday, now: now) == true)
    }

    @Test func relativeLabelDescribesDaysAgo() {
        let calendar = Calendar.current
        let now = calendar.date(from: DateComponents(year: 2026, month: 7, day: 28, hour: 12, minute: 0))!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!
        let label = WearTracker.relativeLabel(lastWorn: threeDaysAgo, now: now)
        #expect(label.contains("3"))
    }
}
