import Vision
import CoreGraphics
import ImageIO

struct ClothingClassification: Equatable {
    let category: ClothingCategory
    let dominantColor: ClosetColor
}

protocol ClothingClassifying {
    func classify(_ image: CGImage, orientation: CGImagePropertyOrientation) async throws -> ClothingClassification
}

struct VisionClothingClassifier: ClothingClassifying {
    private static let fullImageRegion = CGRect(x: 0, y: 0, width: 1, height: 1)

    private let regionDetector: GarmentRegionDetecting

    init(regionDetector: GarmentRegionDetecting = VisionGarmentRegionDetector()) {
        self.regionDetector = regionDetector
    }

    // `orientation` matters: photos from the rear camera come back from
    // UIImagePickerController rotated (their CGImage's raw pixel buffer is
    // sideways relative to how UIImage displays it) — a handler built without
    // it silently classifies the sideways buffer, which is why category
    // guesses on real photos were unreliable.
    func classify(_ image: CGImage, orientation: CGImagePropertyOrientation) async throws -> ClothingClassification {
        let request = VNClassifyImageRequest()
        let handler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])
        try handler.perform([request])

        let identifiers = (request.results ?? [])
            .filter { $0.confidence > 0.1 }
            .map(\.identifier)

        let category = ClothingCategoryMapper.category(forIdentifiers: identifiers)

        // Sample color only over the garment's region, not the whole frame — an
        // uncontrolled background (store shelf, hand, floor) otherwise skews the
        // average toward whatever surrounds the piece instead of the piece itself.
        let region = try? regionDetector.detectRegion(in: image, orientation: orientation)
        let dominantColor = FaceColorSampler.averageColor(in: image, region: region ?? Self.fullImageRegion)

        return ClothingClassification(category: category, dominantColor: dominantColor)
    }
}
