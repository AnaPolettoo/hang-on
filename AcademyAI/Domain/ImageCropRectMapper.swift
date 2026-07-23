import CoreGraphics

enum ImageCropRectMapper {
    /// Converts a crop rectangle drawn in view-local points (over an image displayed
    /// with `.scaledToFit()` inside `containerSize`) into the matching pixel rect in
    /// the source image's own coordinate space, clamped to the image's bounds. Both
    /// coordinate systems share the same top-left origin, so no vertical flip is
    /// needed — the caller must bake the image upright first (`ImageOrientation.upright`),
    /// since `.scaledToFit()` and `CGImage.cropping(to:)` both assume `.up` orientation.
    static func pixelRect(cropRect: CGRect, containerSize: CGSize, imageSize: CGSize) -> CGRect {
        guard containerSize.width > 0, containerSize.height > 0, imageSize.width > 0, imageSize.height > 0 else {
            return CGRect(origin: .zero, size: imageSize)
        }

        let scale = min(containerSize.width / imageSize.width, containerSize.height / imageSize.height)
        let displayedSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let displayOrigin = CGPoint(
            x: (containerSize.width - displayedSize.width) / 2,
            y: (containerSize.height - displayedSize.height) / 2
        )

        let relativeX = (cropRect.origin.x - displayOrigin.x) / scale
        let relativeY = (cropRect.origin.y - displayOrigin.y) / scale
        let width = cropRect.width / scale
        let height = cropRect.height / scale

        let rawRight = relativeX + width
        let rawBottom = relativeY + height

        let clampedX = max(0, min(relativeX, imageSize.width))
        let clampedY = max(0, min(relativeY, imageSize.height))
        let clampedRight = max(0, min(rawRight, imageSize.width))
        let clampedBottom = max(0, min(rawBottom, imageSize.height))

        let clampedWidth = max(0, clampedRight - clampedX)
        let clampedHeight = max(0, clampedBottom - clampedY)

        return CGRect(x: clampedX, y: clampedY, width: clampedWidth, height: clampedHeight)
    }
}
