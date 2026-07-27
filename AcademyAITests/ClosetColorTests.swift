import Testing
@testable import AcademyAI

struct ClosetColorTests {
    @Test func paletteColorsAreDistinctAndInRange() {
        let colors: [ClosetColor] = [
            .warmIvory, .brightAqua, .rust, .olive, .camel, .sage, .mustard,
            .forest, .dustyRose, .plum, .powderBlue, .royalBlue, .charcoal, .hotPink
        ]

        #expect(Set(colors.map(\.key)).count == colors.count)
        for color in colors {
            #expect((0...1).contains(color.red))
            #expect((0...1).contains(color.green))
            #expect((0...1).contains(color.blue))
        }
    }
}

private extension ClosetColor {
    var key: String { "\(red)-\(green)-\(blue)" }
}
