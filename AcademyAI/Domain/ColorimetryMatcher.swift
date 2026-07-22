import Foundation

enum ColorimetryMatcher {
    /// `nil` when there's no colorimetry profile yet (REQ-2.4). Otherwise, `true`
    /// when the sampled color sits closer to the recommended palette than to the
    /// avoid palette (nearest-neighbor by RGB distance), `false` otherwise.
    static func matches(color: ClosetColor, profile: UserColorimetryProfile?) -> Bool? {
        guard let profile else { return nil }

        let closestRecommended = profile.recommendedColors.map { squaredDistance($0, color) }.min()
        let closestAvoid = profile.avoidColors.map { squaredDistance($0, color) }.min()

        switch (closestRecommended, closestAvoid) {
        case (nil, nil): return nil
        case (_?, nil): return true
        case (nil, _?): return false
        case (let recommended?, let avoid?): return recommended <= avoid
        }
    }

    private static func squaredDistance(_ a: ClosetColor, _ b: ClosetColor) -> Double {
        let dr = a.red - b.red, dg = a.green - b.green, db = a.blue - b.blue
        return dr * dr + dg * dg + db * db
    }
}
