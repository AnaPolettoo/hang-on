import CoreImage
import ImageIO

enum ImageOrientation {
    private static let context = CIContext()

    /// Bakes `orientation` into the pixels so downstream Vision/Core Image code
    /// can treat the image as `.up`. Returns the input unchanged when already up.
    static func upright(_ image: CGImage, orientation: CGImagePropertyOrientation) -> CGImage {
        guard orientation != .up else { return image }
        let oriented = CIImage(cgImage: image).oriented(orientation)
        return context.createCGImage(oriented, from: oriented.extent) ?? image
    }
}
