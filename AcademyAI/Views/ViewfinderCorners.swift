import SwiftUI

/// Four camera-viewfinder-style corner brackets overlaid on a rectangular area,
/// matching the Figma "Add a Piece" card decoration (nodes 2120:103–2120:106).
struct ViewfinderCorners: View {
    var color: Color = Theme.Color.cream.opacity(0.85)
    var length: CGFloat = 28
    var lineWidth: CGFloat = 3

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            ZStack {
                corner(from: CGPoint(x: 0, y: length), corner: CGPoint(x: 0, y: 0), to: CGPoint(x: length, y: 0))
                corner(from: CGPoint(x: w - length, y: 0), corner: CGPoint(x: w, y: 0), to: CGPoint(x: w, y: length))
                corner(from: CGPoint(x: w, y: h - length), corner: CGPoint(x: w, y: h), to: CGPoint(x: w - length, y: h))
                corner(from: CGPoint(x: length, y: h), corner: CGPoint(x: 0, y: h), to: CGPoint(x: 0, y: h - length))
            }
        }
        .allowsHitTesting(false)
    }

    private func corner(from start: CGPoint, corner: CGPoint, to end: CGPoint) -> some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: corner)
            path.addLine(to: end)
        }
        .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
    }
}

#Preview {
    ViewfinderCorners()
        .frame(width: 341, height: 224)
        .background(Theme.Color.ink)
}
