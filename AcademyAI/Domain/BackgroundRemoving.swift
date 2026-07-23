import Vision
import CoreImage
import CoreGraphics

struct BackgroundRemovalResult: Equatable {
    let image: CGImage   // subject cropped and centered on a square cream canvas
    let mask: CGImage    // grayscale foreground mask, same frame/size as `image`
}

protocol BackgroundRemoving {
    func removeBackground(from image: CGImage) async throws -> BackgroundRemovalResult?
}

struct VisionBackgroundRemover: BackgroundRemoving {
    // Theme.Color.cream (hex FDFBF7). Domain must not import SwiftUI, so it's a literal.
    private static let cream = CIColor(red: 0.99216, green: 0.98431, blue: 0.96863)
    private static let padding: CGFloat = 0.12 // 12% of the subject's larger side, each side

    private let context = CIContext()

    func removeBackground(from image: CGImage) async throws -> BackgroundRemovalResult? {
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])

        guard let observation = request.results?.first, !observation.allInstances.isEmpty else {
            return nil
        }

        // Foreground pixels only, already cropped tight to the subject's bounding box,
        // with alpha=0 outside it.
        let maskedBuffer = try observation.generateMaskedImage(
            ofInstances: observation.allInstances,
            from: handler,
            croppedToInstancesExtent: true
        )
        let foreground = CIImage(cvPixelBuffer: maskedBuffer)
        let w = foreground.extent.width, h = foreground.extent.height
        guard w > 0, h > 0 else { return nil }

        // Grayscale mask = the foreground's alpha promoted to RGB (white where subject).
        // CIColorMatrix output R/G/B each = input alpha; output alpha forced to 1.
        let grayMask = foreground.applyingFilter("CIColorMatrix", parameters: [
            "inputRVector": CIVector(x: 0, y: 0, z: 0, w: 1),
            "inputGVector": CIVector(x: 0, y: 0, z: 0, w: 1),
            "inputBVector": CIVector(x: 0, y: 0, z: 0, w: 1),
            "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 0),
            "inputBiasVector": CIVector(x: 0, y: 0, z: 0, w: 1),
        ])

        // Square canvas sized to the larger side + padding on both sides; center the subject.
        let side = max(w, h) * (1 + Self.padding * 2)
        let dx = (side - w) / 2, dy = (side - h) / 2
        let square = CGRect(x: 0, y: 0, width: side, height: side)

        func compose(_ subject: CIImage, over background: CIImage) -> CGImage? {
            // Re-origin subject to (0,0) then shift to canvas center.
            let placed = subject
                .transformed(by: CGAffineTransform(translationX: -subject.extent.origin.x, y: -subject.extent.origin.y))
                .transformed(by: CGAffineTransform(translationX: dx, y: dy))
            let composited = placed.composited(over: background.cropped(to: square))
            return context.createCGImage(composited, from: square)
        }

        let creamBg = CIImage(color: Self.cream)
        let blackBg = CIImage(color: CIColor(red: 0, green: 0, blue: 0))

        guard let finalImage = compose(foreground, over: creamBg),
              let finalMask = compose(grayMask, over: blackBg) else {
            return nil
        }

        return BackgroundRemovalResult(image: finalImage, mask: finalMask)
    }
}
