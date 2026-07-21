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

        guard pixelRegion.width > 0, pixelRegion.height > 0,
              let cropped = image.cropping(to: pixelRegion),
              let data = cropped.dataProvider?.data,
              let pointer = CFDataGetBytePtr(data) else {
            return ClosetColor(red: 0, green: 0, blue: 0)
        }

        let bytesPerPixel = max(cropped.bitsPerPixel / 8, 1)
        let bytesPerRow = cropped.bytesPerRow
        var totalRed = 0.0, totalGreen = 0.0, totalBlue = 0.0, count = 0.0

        for y in 0..<cropped.height {
            for x in 0..<cropped.width {
                let offset = y * bytesPerRow + x * bytesPerPixel
                totalRed += Double(pointer[offset]) / 255.0
                totalGreen += Double(pointer[offset + 1]) / 255.0
                totalBlue += Double(pointer[offset + 2]) / 255.0
                count += 1
            }
        }

        guard count > 0 else { return ClosetColor(red: 0, green: 0, blue: 0) }
        return ClosetColor(red: totalRed / count, green: totalGreen / count, blue: totalBlue / count)
    }
}
