import Vision
import CoreGraphics

struct FaceRegions: Equatable {
    let skinRegion: CGRect
    let eyeRegion: CGRect
    let hairRegion: CGRect
}

protocol FaceRegionDetecting {
    func detectRegions(in image: CGImage) async throws -> FaceRegions?
}

struct VisionFaceRegionDetector: FaceRegionDetecting {
    func detectRegions(in image: CGImage) async throws -> FaceRegions? {
        let request = VNDetectFaceLandmarksRequest()
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])

        guard let face = request.results?.first else { return nil }

        let faceBounds = face.boundingBox

        let skinRegion = CGRect(
            x: faceBounds.midX - faceBounds.width * 0.1,
            y: faceBounds.midY - faceBounds.height * 0.05,
            width: faceBounds.width * 0.2,
            height: faceBounds.height * 0.1
        )

        let eyeRegion: CGRect
        if let leftEye = face.landmarks?.leftEye {
            eyeRegion = boundingBox(of: leftEye.normalizedPoints, in: faceBounds)
        } else {
            eyeRegion = CGRect(
                x: faceBounds.midX - 0.05,
                y: faceBounds.maxY - faceBounds.height * 0.3,
                width: 0.1,
                height: 0.05
            )
        }

        let hairHeight = min(faceBounds.height * 0.2, max(1.0 - faceBounds.maxY, 0.01))
        let hairRegion = CGRect(
            x: faceBounds.minX,
            y: min(faceBounds.maxY + faceBounds.height * 0.05, 1.0 - hairHeight),
            width: faceBounds.width,
            height: hairHeight
        )

        let unitBounds = CGRect(x: 0, y: 0, width: 1, height: 1)
        return FaceRegions(
            skinRegion: flippedToTopLeftOrigin(skinRegion).intersection(unitBounds),
            eyeRegion: flippedToTopLeftOrigin(eyeRegion).intersection(unitBounds),
            hairRegion: flippedToTopLeftOrigin(hairRegion)
        )
    }

    private func boundingBox(of points: [CGPoint], in faceBounds: CGRect) -> CGRect {
        guard !points.isEmpty else { return faceBounds }
        let xs = points.map { faceBounds.origin.x + $0.x * faceBounds.width }
        let ys = points.map { faceBounds.origin.y + $0.y * faceBounds.height }
        let minX = xs.min()!, maxX = xs.max()!
        let minY = ys.min()!, maxY = ys.max()!
        return CGRect(x: minX, y: minY, width: max(maxX - minX, 0.02), height: max(maxY - minY, 0.02))
    }

    /// Vision's `VNFaceObservation.boundingBox` (and everything derived from it above)
    /// lives in Vision's native coordinate space: origin bottom-left, y increasing
    /// upward. `FaceColorSampler` expects the opposite: origin top-left, y increasing
    /// downward. Flip once here, at the boundary, so `FaceRegions` genuinely means
    /// "top-left origin" for every consumer.
    private func flippedToTopLeftOrigin(_ rect: CGRect) -> CGRect {
        CGRect(x: rect.origin.x, y: 1 - rect.origin.y - rect.height, width: rect.width, height: rect.height)
    }
}
