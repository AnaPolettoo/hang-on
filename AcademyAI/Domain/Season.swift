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
        case .warmSpring: return String(localized: "Warm Spring")
        case .lightSpring: return String(localized: "Light Spring")
        case .clearSpring: return String(localized: "Clear Spring")
        case .coolSummer: return String(localized: "Cool Summer")
        case .lightSummer: return String(localized: "Light Summer")
        case .softSummer: return String(localized: "Soft Summer")
        case .warmAutumn: return String(localized: "Warm Autumn")
        case .softAutumn: return String(localized: "Soft Autumn")
        case .deepAutumn: return String(localized: "Deep Autumn")
        case .coolWinter: return String(localized: "Cool Winter")
        case .clearWinter: return String(localized: "Clear Winter")
        case .deepWinter: return String(localized: "Deep Winter")
        }
    }
}
