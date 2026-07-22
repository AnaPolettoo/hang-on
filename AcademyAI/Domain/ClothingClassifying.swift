import Vision
import CoreGraphics

struct ClothingClassification: Equatable {
    let category: ClothingCategory
    let dominantColor: ClosetColor
}

protocol ClothingClassifying {
    func classify(_ image: CGImage) async throws -> ClothingClassification
}

struct VisionClothingClassifier: ClothingClassifying {
    private static let fullImageRegion = CGRect(x: 0, y: 0, width: 1, height: 1)

    func classify(_ image: CGImage) async throws -> ClothingClassification {
        let request = VNClassifyImageRequest()
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])

        let identifiers = (request.results ?? [])
            .filter { $0.confidence > 0.1 }
            .map(\.identifier)

        let category = ClothingCategoryMapper.category(forIdentifiers: identifiers)
        let dominantColor = FaceColorSampler.averageColor(in: image, region: Self.fullImageRegion)

        return ClothingClassification(category: category, dominantColor: dominantColor)
    }
}
