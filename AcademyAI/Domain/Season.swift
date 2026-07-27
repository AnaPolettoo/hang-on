import Foundation

/// The 12 subseasons of professional colorimetry. Each belongs to one of the
/// four classic families and differs from its two siblings by how vivid or
/// muted the person reads.
enum Season: String, Codable, CaseIterable {
    case warmSpring, lightSpring, clearSpring
    case coolSummer, lightSummer, softSummer
    case warmAutumn, softAutumn, deepAutumn
    case coolWinter, clearWinter, deepWinter

    var displayName: String {
        switch self {
        case .warmSpring: return "Warm Spring"
        case .lightSpring: return "Light Spring"
        case .clearSpring: return "Clear Spring"
        case .coolSummer: return "Cool Summer"
        case .lightSummer: return "Light Summer"
        case .softSummer: return "Soft Summer"
        case .warmAutumn: return "Warm Autumn"
        case .softAutumn: return "Soft Autumn"
        case .deepAutumn: return "Deep Autumn"
        case .coolWinter: return "Cool Winter"
        case .clearWinter: return "Clear Winter"
        case .deepWinter: return "Deep Winter"
        }
    }
}
