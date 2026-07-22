import Vision
import CoreGraphics
import ImageIO

protocol GarmentRegionDetecting {
    func detectRegion(in image: CGImage, orientation: CGImagePropertyOrientation) throws -> CGRect?
}

// Isolates the garment from an uncontrolled background (product doc's "decisão em
// aberto #1": store photos have non-neutral backgrounds/lighting, which polluted the
// dominant-color sample when it was averaged over the whole frame). Vision's
// attention-based saliency picks out the main subject's bounding box — no per-pixel
// mask needed for a color average, just the region to average over.
struct VisionGarmentRegionDetector: GarmentRegionDetecting {
    func detectRegion(in image: CGImage, orientation: CGImagePropertyOrientation) throws -> CGRect? {
        let request = VNGenerateAttentionBasedSaliencyImageRequest()
        let handler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])
        try handler.perform([request])

        guard let objects = request.results?.first?.salientObjects, !objects.isEmpty else {
            return nil
        }

        let largest = objects.max {
            $0.boundingBox.width * $0.boundingBox.height < $1.boundingBox.width * $1.boundingBox.height
        }!

        // Vision's boundingBox uses a bottom-left origin, y-up space; flip to the
        // top-left, y-down convention FaceColorSampler's `region` expects (same
        // conversion FaceRegionDetecting already does for face landmarks).
        let box = largest.boundingBox
        return CGRect(x: box.origin.x, y: 1 - box.origin.y - box.height, width: box.width, height: box.height)
    }
}
