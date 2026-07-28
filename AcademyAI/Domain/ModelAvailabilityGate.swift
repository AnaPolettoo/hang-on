import FoundationModels

enum ModelAvailabilityError: Error, Equatable {
    case deviceNotEligible
    case notEnabled
    case notReady

    var message: String {
        switch self {
        case .deviceNotEligible:
            return "This device can't run Hang On's AI stylist. You can still catalogue pieces and browse your closet."
        case .notEnabled:
            return "Turn on Apple Intelligence in Settings to get a stylist verdict on this piece."
        case .notReady:
            return "Apple Intelligence is still getting ready on this device. Try again shortly."
        }
    }
}

enum ModelAvailabilityGate {
    static func check(_ availability: SystemLanguageModel.Availability = SystemLanguageModel.default.availability) throws {
        guard case .unavailable(let reason) = availability else { return }
        switch reason {
        case .deviceNotEligible:
            throw ModelAvailabilityError.deviceNotEligible
        case .appleIntelligenceNotEnabled:
            throw ModelAvailabilityError.notEnabled
        case .modelNotReady:
            throw ModelAvailabilityError.notReady
        @unknown default:
            throw ModelAvailabilityError.notReady
        }
    }
}
