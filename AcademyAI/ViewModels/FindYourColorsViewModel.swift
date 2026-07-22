import Foundation
import SwiftData
import CoreGraphics
import Observation

@Observable
final class FindYourColorsViewModel {
    var isProcessing = false
    var errorMessage: String?
    var result: (season: Season, recommended: [ClosetColor], avoid: [ClosetColor], explanation: String)?

    private let regionDetector: FaceRegionDetecting
    private let explanationGenerator: PaletteExplanationGenerating
    private let modelContext: ModelContext

    init(
        regionDetector: FaceRegionDetecting = VisionFaceRegionDetector(),
        explanationGenerator: PaletteExplanationGenerating = FoundationModelsPaletteExplainer(),
        modelContext: ModelContext
    ) {
        self.regionDetector = regionDetector
        self.explanationGenerator = explanationGenerator
        self.modelContext = modelContext
    }

    func processSelfie(_ image: CGImage, name: String?) async {
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }

        do {
            guard let regions = try await regionDetector.detectRegions(in: image) else {
                errorMessage = "Não encontramos seu rosto. Tenta de novo com boa luz, sem contraluz."
                return
            }

            let skin = FaceColorSampler.averageColor(in: image, region: regions.skinRegion)
            let eye = FaceColorSampler.averageColor(in: image, region: regions.eyeRegion)
            let hair = FaceColorSampler.averageColor(in: image, region: regions.hairRegion)

            let season = SeasonClassifier.classify(skinTone: skin, eyeColor: eye, hairColor: hair)
            let recommended = SeasonPalette.recommendedColors(for: season)
            let avoid = SeasonPalette.avoidColors(for: season)
            let explanation = try await explanationGenerator.generateExplanation(season: season, recommendedColors: recommended)

            let profile = UserColorimetryProfile(
                name: name,
                skinToneSample: skin,
                eyeColorSample: eye,
                hairColorSample: hair,
                season: season,
                recommendedColors: recommended,
                avoidColors: avoid
            )
            modelContext.insert(profile)
            try modelContext.save()

            result = (season, recommended, avoid, explanation)
        } catch {
            errorMessage = "Algo deu errado. Tenta de novo."
        }
    }
}
