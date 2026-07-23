import SwiftUI

struct CropPhotoView: View {
    let image: UIImage
    let onCrop: (UIImage) -> Void
    let onCancel: () -> Void

    @State private var cropRect: CGRect = .zero
    @State private var containerSize: CGSize = .zero
    @State private var dragStartRect: CGRect = .zero

    private let handleSize: CGFloat = 28
    // Floor on crop box width/height. Clamping to this (rather than letting a drag
    // shrink or invert the rect past zero) keeps the box well-formed through
    // aggressive corner drags, at the cost of not being pixel-perfect at the extreme.
    private let minCropSize: CGFloat = 60

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { proxy in
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: proxy.size.width, height: proxy.size.height)

                    dimOverlay(containerSize: proxy.size)
                    cropBox
                }
                .onAppear {
                    containerSize = proxy.size
                    cropRect = defaultCropRect(in: proxy.size)
                }
            }
            .background(Color.black)

            HStack(spacing: 12) {
                Button("Cancel") { onCancel() }
                    .buttonStyle(.closetDashed)
                Button("Use Crop") { confirmCrop() }
                    .buttonStyle(.closetPrimary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Theme.Color.cream)
        }
        .navigationTitle("Crop Photo")
        .navigationBarTitleDisplayMode(.inline)
        .background(Theme.Color.cream.ignoresSafeArea())
    }

    private func defaultCropRect(in size: CGSize) -> CGRect {
        let inset: CGFloat = 32
        return CGRect(x: inset, y: inset, width: max(minCropSize, size.width - inset * 2), height: max(minCropSize, size.height - inset * 2))
    }

    private func dimOverlay(containerSize: CGSize) -> some View {
        Path { path in
            path.addRect(CGRect(origin: .zero, size: containerSize))
            path.addRect(cropRect)
        }
        .fill(Color.black.opacity(0.55), style: FillStyle(eoFill: true))
        .allowsHitTesting(false)
    }

    private enum Corner: CaseIterable {
        case topLeft, topRight, bottomLeft, bottomRight

        func point(in rect: CGRect) -> CGPoint {
            switch self {
            case .topLeft: return CGPoint(x: rect.minX, y: rect.minY)
            case .topRight: return CGPoint(x: rect.maxX, y: rect.minY)
            case .bottomLeft: return CGPoint(x: rect.minX, y: rect.maxY)
            case .bottomRight: return CGPoint(x: rect.maxX, y: rect.maxY)
            }
        }
    }

    private var cropBox: some View {
        ZStack {
            Rectangle()
                .stroke(Theme.Color.cream, lineWidth: 2)
                .frame(width: cropRect.width, height: cropRect.height)
                .position(x: cropRect.midX, y: cropRect.midY)
                .gesture(moveGesture)

            ForEach(Corner.allCases, id: \.self) { corner in
                Circle()
                    .fill(Theme.Color.cream)
                    .frame(width: handleSize, height: handleSize)
                    .position(corner.point(in: cropRect))
                    .gesture(resizeGesture(for: corner))
            }
        }
    }

    private var moveGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if dragStartRect == .zero { dragStartRect = cropRect }
                var rect = dragStartRect
                rect.origin.x += value.translation.width
                rect.origin.y += value.translation.height
                cropRect = clamp(rect, in: containerSize)
            }
            .onEnded { _ in dragStartRect = .zero }
    }

    private func resizeGesture(for corner: Corner) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if dragStartRect == .zero { dragStartRect = cropRect }
                var rect = dragStartRect
                switch corner {
                case .topLeft:
                    rect.origin.x += value.translation.width
                    rect.origin.y += value.translation.height
                    rect.size.width -= value.translation.width
                    rect.size.height -= value.translation.height
                case .topRight:
                    rect.origin.y += value.translation.height
                    rect.size.width += value.translation.width
                    rect.size.height -= value.translation.height
                case .bottomLeft:
                    rect.origin.x += value.translation.width
                    rect.size.width -= value.translation.width
                    rect.size.height += value.translation.height
                case .bottomRight:
                    rect.size.width += value.translation.width
                    rect.size.height += value.translation.height
                }
                cropRect = clamp(rect, in: containerSize)
            }
            .onEnded { _ in dragStartRect = .zero }
    }

    private func clamp(_ rect: CGRect, in bounds: CGSize) -> CGRect {
        var r = rect
        r.size.width = max(minCropSize, r.size.width)
        r.size.height = max(minCropSize, r.size.height)
        if r.size.width > bounds.width { r.size.width = bounds.width }
        if r.size.height > bounds.height { r.size.height = bounds.height }
        r.origin.x = max(0, min(r.origin.x, bounds.width - r.size.width))
        r.origin.y = max(0, min(r.origin.y, bounds.height - r.size.height))
        return r
    }

    private func confirmCrop() {
        let pixelRect = ImageCropRectMapper.pixelRect(cropRect: cropRect, containerSize: containerSize, imageSize: image.size)
        guard let cgImage = image.cgImage?.cropping(to: pixelRect) else {
            onCancel()
            return
        }
        onCrop(UIImage(cgImage: cgImage))
    }
}
