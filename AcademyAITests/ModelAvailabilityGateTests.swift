import Testing
import FoundationModels
@testable import AcademyAI

@Test func availableModelDoesNotThrow() throws {
    try ModelAvailabilityGate.check(.available)
}

@Test func deviceNotEligibleThrowsWithDistinctMessage() {
    #expect(throws: ModelAvailabilityError.deviceNotEligible) {
        try ModelAvailabilityGate.check(.unavailable(.deviceNotEligible))
    }
}

@Test func appleIntelligenceNotEnabledThrowsWithDistinctMessage() {
    #expect(throws: ModelAvailabilityError.notEnabled) {
        try ModelAvailabilityGate.check(.unavailable(.appleIntelligenceNotEnabled))
    }
}

@Test func modelNotReadyThrowsWithDistinctMessage() {
    #expect(throws: ModelAvailabilityError.notReady) {
        try ModelAvailabilityGate.check(.unavailable(.modelNotReady))
    }
}
