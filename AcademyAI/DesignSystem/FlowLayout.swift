import SwiftUI

/// Wraps subviews left-to-right, starting a new row when the next one doesn't fit
/// the available width — used for chip/pill rows (color and category pickers)
/// that don't all fit on one line at every device width.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var rowSpacing: CGFloat = 8
    var horizontalAlignment: HorizontalAlignment = .leading

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let computedRows = rows(for: subviews, maxWidth: maxWidth)
        let height = computedRows.reduce(0) { $0 + $1.height } + rowSpacing * CGFloat(max(0, computedRows.count - 1))
        let width = computedRows.map(\.width).max() ?? 0
        return CGSize(width: maxWidth.isFinite ? maxWidth : width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in rows(for: subviews, maxWidth: bounds.width) {
            var x = bounds.minX
            if horizontalAlignment == .center {
                x += (bounds.width - row.width) / 2
            }
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: .unspecified)
                x += size.width + spacing
            }
            y += row.height + rowSpacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func rows(for subviews: Subviews, maxWidth: CGFloat) -> [Row] {
        var computedRows: [Row] = []
        var current = Row()
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let widthWithItem = current.indices.isEmpty ? size.width : current.width + spacing + size.width
            if widthWithItem > maxWidth, !current.indices.isEmpty {
                computedRows.append(current)
                current = Row(indices: [index], width: size.width, height: size.height)
            } else {
                current.indices.append(index)
                current.width = widthWithItem
                current.height = max(current.height, size.height)
            }
        }
        if !current.indices.isEmpty { computedRows.append(current) }
        return computedRows
    }
}
