import CoreGraphics

enum FaceColorSampler {
    static func averageColor(in image: CGImage, region: CGRect) -> ClosetColor {
        let width = image.width
        let height = image.height

        let pixelRegion = CGRect(
            x: region.origin.x * CGFloat(width),
            y: region.origin.y * CGFloat(height),
            width: region.width * CGFloat(width),
            height: region.height * CGFloat(height)
        ).integral

        guard pixelRegion.width > 0, pixelRegion.height > 0 else {
            return ClosetColor(red: 0, green: 0, blue: 0)
        }

        let cropWidth = Int(pixelRegion.width)
        let cropHeight = Int(pixelRegion.height)
        guard cropWidth > 0, cropHeight > 0 else {
            return ClosetColor(red: 0, green: 0, blue: 0)
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var pixelData = [UInt8](repeating: 0, count: cropWidth * cropHeight * 4)
        guard let context = CGContext(
            data: &pixelData,
            width: cropWidth,
            height: cropHeight,
            bitsPerComponent: 8,
            bytesPerRow: cropWidth * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return ClosetColor(red: 0, green: 0, blue: 0)
        }

        // CGContext draws images in a bottom-left-origin, y-up space, while `region`
        // (and pixelRegion derived from it) uses a top-left-origin, y-down convention.
        // Flip the y offset so the requested region lands at (0,0) of this context:
        // the image's top edge (pixelRegion.maxY) must map to the context's top edge.
        let yOffset = -(CGFloat(height) - pixelRegion.maxY)
        context.draw(image, in: CGRect(
            x: -pixelRegion.origin.x,
            y: yOffset,
            width: CGFloat(width),
            height: CGFloat(height)
        ))

        var totalRed = 0.0, totalGreen = 0.0, totalBlue = 0.0, count = 0.0
        let bytesPerRow = cropWidth * 4
        for y in 0..<cropHeight {
            for x in 0..<cropWidth {
                let offset = y * bytesPerRow + x * 4
                totalRed += Double(pixelData[offset]) / 255.0
                totalGreen += Double(pixelData[offset + 1]) / 255.0
                totalBlue += Double(pixelData[offset + 2]) / 255.0
                count += 1
            }
        }

        guard count > 0 else { return ClosetColor(red: 0, green: 0, blue: 0) }
        return ClosetColor(red: totalRed / count, green: totalGreen / count, blue: totalBlue / count)
    }
}
