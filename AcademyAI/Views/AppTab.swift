import Foundation

enum AppTab: Hashable, CaseIterable {
    case check, analysis, closet

    var title: String {
        switch self {
        case .check: return "Check"
        case .analysis: return "Analysis"
        case .closet: return "Closet"
        }
    }

    var iconName: String {
        switch self {
        case .check: return "TabIconCheck"
        case .analysis: return "TabIconAnalysis"
        case .closet: return "TabIconCloset"
        }
    }
}
