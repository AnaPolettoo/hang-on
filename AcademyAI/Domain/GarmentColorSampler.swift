import CoreGraphics

/// Dominant color by mode, not mean. Averaging a red-and-white striped shirt
/// yields pink — a color that appears nowhere on the garment. Counting quantized
/// colors and returning the most common one always yields a real color.
///
/// This deliberately does *not* try to detect whether a garment is patterned.
/// The obvious signal — how much of the garment the winning bin covers — was
/// measured against real product photos and marked every solid garment as
/// patterned: folds and shading spread one color across many neighboring bins.
/// Pattern is a manual toggle on the review screen instead.
///
/// Deliberately separate from `FaceColorSampler`, which keeps averaging for the
/// colorimetry path: skin is a near-uniform surface with no pattern problem, and
/// changing it would silently move the season of every saved profile. The pixel
/// geometry below is duplicated from it for the same reason.
enum GarmentColorSampler {
    private static let black = ClosetColor(red: 0, green: 0, blue: 0)

    /// 3 bits per channel. Coarse on purpose: a solid garment photographed with
    /// folds and shadow spreads across neighboring bins, so finer bins would
    /// splinter one real color into many. Precision isn't lost — the returned
    /// color is the mean of the winning bin's pixels, not the bin's center.
    private static let levelsPerChannel = 8
    private static let binCount = levelsPerChannel * levelsPerChannel * levelsPerChannel

    static func dominantColor(in image: CGImage, mask: CGImage) -> ClosetColor {
        let width = image.width, height = image.height
        guard width > 0, height > 0 else { return black }

        guard let imageData = drawFullSize(image, width: width, height: height),
              let maskData = drawFullSize(mask, width: width, height: height)
        else { return black }

        // Same foreground rule the previous implementation used: mask red > 127.
        return summarize(pixels: imageData) { maskData[$0] > 127 }
    }

    static func dominantColor(in image: CGImage, region: CGRect) -> ClosetColor {
        let width = image.width, height = image.height

        let pixelRegion = CGRect(
            x: region.origin.x * CGFloat(width),
            y: region.origin.y * CGFloat(height),
            width: region.width * CGFloat(width),
            height: region.height * CGFloat(height)
        ).integral

        let cropWidth = Int(pixelRegion.width), cropHeight = Int(pixelRegion.height)
        guard cropWidth > 0, cropHeight > 0 else { return black }

        var pixelData = [UInt8](repeating: 0, count: cropWidth * cropHeight * 4)
        guard let context = CGContext(
            data: &pixelData,
            width: cropWidth,
            height: cropHeight,
            bitsPerComponent: 8,
            bytesPerRow: cropWidth * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return black }

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

        return summarize(pixels: pixelData) { _ in true }
    }

    private static func drawFullSize(_ cgImage: CGImage, width: Int, height: Int) -> [UInt8]? {
        var data = [UInt8](repeating: 0, count: width * height * 4)
        guard let context = CGContext(
            data: &data,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return data
    }

    /// `includePixel` receives the byte offset of each pixel's red channel.
    private static func summarize(
        pixels: [UInt8],
        includePixel: (Int) -> Bool
    ) -> ClosetColor {
        var counts = [Int](repeating: 0, count: binCount)
        var sumRed = [Double](repeating: 0, count: binCount)
        var sumGreen = [Double](repeating: 0, count: binCount)
        var sumBlue = [Double](repeating: 0, count: binCount)
        var total = 0

        for offset in stride(from: 0, to: pixels.count, by: 4) where includePixel(offset) {
            let red = pixels[offset], green = pixels[offset + 1], blue = pixels[offset + 2]
            let bin = level(red) * levelsPerChannel * levelsPerChannel
                + level(green) * levelsPerChannel
                + level(blue)
            counts[bin] += 1
            sumRed[bin] += Double(red) / 255.0
            sumGreen[bin] += Double(green) / 255.0
            sumBlue[bin] += Double(blue) / 255.0
            total += 1
        }

        guard total > 0 else { return black }

        // Strict `>` keeps the lowest bin index on ties, so the same photo always
        // resolves to the same color.
        var winner = 0
        for bin in 1..<binCount where counts[bin] > counts[winner] {
            winner = bin
        }
        guard counts[winner] > 0 else { return black }

        let winnerCount = Double(counts[winner])
        return ClosetColor(
            red: sumRed[winner] / winnerCount,
            green: sumGreen[winner] / winnerCount,
            blue: sumBlue[winner] / winnerCount
        )
    }

    private static func level(_ channel: UInt8) -> Int {
        Int(channel) * levelsPerChannel / 256
    }
}
