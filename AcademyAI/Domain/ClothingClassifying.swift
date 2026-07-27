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

    /// The model was trained on product photos shot over white. What reaches it
    /// here is the composite from `VisionBackgroundRemover`, which is transparent
    /// outside the garment — and Vision renders transparent as *black* when it
    /// feeds the model. Three quarters of that canvas is background, so the model
    /// was being asked about a garment floating on black, which it never saw in
    /// training. Measured on the held-out set: 92% top-1 on the raw photos,
    /// 85% through the transparent composite, back to 92% flattened onto white.
    private static func flattenedOnWhite(_ image: CGImage) -> CGImage {
        let width = image.width, height = image.height
        guard width > 0, height > 0,
              let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
              )
        else { return image }

        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        context.setFillColor(gray: 1, alpha: 1)
        context.fill(frame)
        context.draw(image, in: frame)
        return context.makeImage() ?? image
    }

    // `orientation` matters: photos from the rear camera come back from
    // UIImagePickerController rotated (their CGImage's raw pixel buffer is
    // sideways relative to how UIImage displays it) — a handler built without
    // it silently classifies the sideways buffer, which is why category
    // guesses on real photos were unreliable.
    func classify(_ image: CGImage, orientation: CGImagePropertyOrientation, mask: CGImage? = nil) async throws -> ClothingClassification {
        var topLabel = ""
        var confidence: Float = 0
        if let visionModel = Self.visionModel {
            // Only the model sees the flattened copy. `image` keeps its alpha for
            // the color sampling below and for the picture the person ends up
            // seeing in their closet.
            let handler = VNImageRequestHandler(
                cgImage: Self.flattenedOnWhite(image),
                orientation: orientation,
                options: [:]
            )
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
