import Vision
import CoreML
import CoreGraphics
import ImageIO

struct ClothingClassification: Equatable {
    let category: ClothingCategory
    let dominantColor: ClosetColor
    /// Vision's top raw classification confidence (0-1), before category-keyword
    /// mapping. Feature 3 (REQ-3.2) gates on this to catch a bad store-photo read
    /// (uncontrolled background/lighting) without re-running Vision. Defaults to 1
    /// so existing call sites/tests that don't care about confidence are unaffected.
    let confidence: Float

    init(category: ClothingCategory, dominantColor: ClosetColor, confidence: Float = 1.0) {
        self.category = category
        self.dominantColor = dominantColor
        self.confidence = confidence
    }
}

protocol ClothingClassifying {
    func classify(_ image: CGImage, orientation: CGImagePropertyOrientation, mask: CGImage?) async throws -> ClothingClassification
}

struct VisionClothingClassifier: ClothingClassifying {
    private static let fullImageRegion = CGRect(x: 0, y: 0, width: 1, height: 1)

    // Carregado uma vez: instanciar o modelo por chamada custa caro e a foto
    // é classificada em fluxo interativo (catalogar peça / validar compra).
    private static let visionModel: VNCoreMLModel? = {
        guard let wrapped = try? GarmentCategoryClassifier(configuration: MLModelConfiguration()) else { return nil }
        return try? VNCoreMLModel(for: wrapped.model)
    }()

    private let regionDetector: GarmentRegionDetecting

    init(regionDetector: GarmentRegionDetecting = VisionGarmentRegionDetector()) {
        self.regionDetector = regionDetector
    }

    // `orientation` matters: photos from the rear camera come back from
    // UIImagePickerController rotated (their CGImage's raw pixel buffer is
    // sideways relative to how UIImage displays it) — a handler built without
    // it silently classifies the sideways buffer, which is why category
    // guesses on real photos were unreliable.
    func classify(_ image: CGImage, orientation: CGImagePropertyOrientation, mask: CGImage? = nil) async throws -> ClothingClassification {
        let handler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])

        var topLabel = ""
        var confidence: Float = 0
        if let visionModel = Self.visionModel {
            let request = VNCoreMLRequest(model: visionModel)
            // A peça já vem recortada e centralizada num canvas quadrado pelo
            // VisionBackgroundRemover — centerCrop não corta nada relevante.
            request.imageCropAndScaleOption = .centerCrop
            try handler.perform([request])
            if let top = (request.results as? [VNClassificationObservation])?.first {
                topLabel = top.identifier
                confidence = top.confidence
            }
        }

        let category = GarmentLabelMapper.category(forLabel: topLabel, confidence: confidence)

        // With a foreground mask, sample color only over the garment's pixels.
        // Without one, fall back to the saliency bounding box (previous behavior).
        let dominantColor: ClosetColor
        if let mask {
            dominantColor = GarmentColorSampler.dominantColor(in: image, mask: mask)
        } else {
            let region = try? regionDetector.detectRegion(in: image, orientation: orientation)
            dominantColor = GarmentColorSampler.dominantColor(in: image, region: region ?? Self.fullImageRegion)
        }

        return ClothingClassification(category: category, dominantColor: dominantColor, confidence: confidence)
    }
}
