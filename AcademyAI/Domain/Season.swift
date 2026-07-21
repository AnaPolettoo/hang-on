import Foundation

enum Season: String, Codable, CaseIterable {
    case spring, summer, autumn, winter

    var opposite: Season {
        switch self {
        case .spring: return .winter
        case .winter: return .spring
        case .summer: return .autumn
        case .autumn: return .summer
        }
    }
}
