import CoreGraphics

struct GarmentColorSample: Equatable {
    let dominantColor: ClosetColor
    /// True when no single quantized color covers enough of the garment.
    let isPatterned: Bool

    static let empty = GarmentColorSample(
        dominantColor: ClosetColor(red: 0, green: 0, blue: 0),
        isPatterned: false
    )
}

/// Dominant color by mode, not mean. Averaging a red-and-white striped shirt
/// yields pink — a color that appears nowhere on the garment. Counting quantized
/// colors and returning the most common one always yields a real color, and the
/// same count tells us whether the garment is patterned at all.
///
/// Deliberately separate from `FaceColorSampler`, which keeps averaging for the
/// colorimetry path: skin is a near-uniform surface with no pattern problem, and
/// changing it would silently move the season of every saved profile. The pixel
/// geometry below is duplicated from it for the same reason.
enum GarmentColorSampler {
    /// 3 bits per channel. Coarse on purpose: a solid garment photographed with
    /// folds and shadow spreads across neighboring bins, and finer bins would
    /// read that shadow as a pattern. Precision isn't lost — the returned color
    /// is the mean of the winning bin's pixels, not the bin's center.
    private static let levelsPerChannel = 8
    private static let binCount = levelsPerChannel * levelsPerChannel * levelsPerChannel
    private static let patternThreshold = 0.5

    static func sample(in image: CGImage, mask: CGImage) -> GarmentColorSample {
        let width = image.width, height = image.height
        guard width > 0, height > 0 else { return .empty }

        guard let imageData = drawFullSize(image, width: width, height: height),
              let maskData = drawFullSize(mask, width: width, height: height)
        else { return .empty }

        // Same foreground rule the previous implementation used: mask red > 127.
        return summarize(pixels: imageData) { maskData[$0] > 127 }
    }

    static func sample(in image: CGImage, region: CGRect) -> GarmentColorSample {
        let width = image.width, height = image.height

        let pixelRegion = CGRect(
            x: region.origin.x * CGFloat(width),
            y: region.origin.y * CGFloat(height),
            width: region.width * CGFloat(width),
            height: region.height * CGFloat(height)
        ).integral

        let cropWidth = Int(pixelRegion.width), cropHeight = Int(pixelRegion.height)
        guard cropWidth > 0, cropHeight > 0 else { return .empty }

        var pixelData = [UInt8](repeating: 0, count: cropWidth * cropHeight * 4)
        guard let context = CGContext(
            data: &pixelData,
            width: cropWidth,
            height: cropHeight,
            bitsPerComponent: 8,
            bytesPerRow: cropWidth * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return .empty }

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
    ) -> GarmentColorSample {
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

        guard total > 0 else { return .empty }

        // Strict `>` keeps the lowest bin index on ties, so the same photo always
        // resolves to the same color.
        var winner = 0
        for bin in 1..<binCount where counts[bin] > counts[winner] {
            winner = bin
        }
        guard counts[winner] > 0 else { return .empty }

        let winnerCount = Double(counts[winner])
        return GarmentColorSample(
            dominantColor: ClosetColor(
                red: sumRed[winner] / winnerCount,
                green: sumGreen[winner] / winnerCount,
                blue: sumBlue[winner] / winnerCount
            ),
            isPatterned: winnerCount / Double(total) < patternThreshold
        )
    }

    private static func level(_ channel: UInt8) -> Int {
        Int(channel) * levelsPerChannel / 256
    }
}
