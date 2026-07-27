import Testing
import CoreGraphics
@testable import AcademyAI

/// Builds a `width x 1` image from an explicit pixel list, so each test states
/// its pixel distribution literally instead of relying on drawing behavior.
private func makeStripImage(_ pixels: [(UInt8, UInt8, UInt8)]) -> CGImage {
    let width = pixels.count
    var data = [UInt8](repeating: 0, count: width * 4)
    for (index, pixel) in pixels.enumerated() {
        data[index * 4] = pixel.0
        data[index * 4 + 1] = pixel.1
        data[index * 4 + 2] = pixel.2
        data[index * 4 + 3] = 255
    }
    let context = CGContext(
        data: &data, width: width, height: 1, bitsPerComponent: 8,
        bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    return context.makeImage()!
}

private let fullRegion = CGRect(x: 0, y: 0, width: 1, height: 1)

struct GarmentColorSamplerTests {
    @Test func solidGarmentReturnsItsColorAndIsNotPatterned() {
        let image = makeStripImage(Array(repeating: (200, 50, 50), count: 10))
        let sample = GarmentColorSampler.sample(in: image, region: fullRegion)

        #expect(abs(sample.dominantColor.red - 200.0 / 255) < 0.01)
        #expect(abs(sample.dominantColor.green - 50.0 / 255) < 0.01)
        #expect(abs(sample.dominantColor.blue - 50.0 / 255) < 0.01)
        #expect(!sample.isPatterned)
    }

    // O teste que protege contra sombra virar estampa: duas tonalidades da mesma
    // cor caem no mesmo bin, então a peça segue lisa e a cor é a média das duas.
    @Test func shadingWithinOneBinStaysUnpatterned() {
        let image = makeStripImage(
            Array(repeating: (200, 50, 50), count: 5) + Array(repeating: (210, 55, 58), count: 5)
        )
        let sample = GarmentColorSampler.sample(in: image, region: fullRegion)

        #expect(!sample.isPatterned)
        #expect(abs(sample.dominantColor.red - 205.0 / 255) < 0.01)
    }

    // O teste que prova que a moda substituiu a média: com três cores em partes
    // desiguais, o resultado é a cor mais frequente — nunca a média das três,
    // que seria um cinza que não existe na peça.
    @Test func threeColorPatternReturnsTheMostFrequentColor() {
        let image = makeStripImage(
            Array(repeating: (255, 0, 0), count: 4)
                + Array(repeating: (0, 255, 0), count: 3)
                + Array(repeating: (0, 0, 255), count: 3)
        )
        let sample = GarmentColorSampler.sample(in: image, region: fullRegion)

        #expect(sample.isPatterned)
        #expect(abs(sample.dominantColor.red - 1.0) < 0.01)
        #expect(abs(sample.dominantColor.green - 0.0) < 0.01)
        #expect(abs(sample.dominantColor.blue - 0.0) < 0.01)
    }

    @Test func maskExcludesBackgroundFromBothColorAndFlag() {
        // 4 px de peça vermelha, 6 px de fundo verde. Sem máscara o verde venceria.
        let image = makeStripImage(
            Array(repeating: (200, 50, 50), count: 4) + Array(repeating: (0, 255, 0), count: 6)
        )
        let mask = makeStripImage(
            Array(repeating: (255, 255, 255), count: 4) + Array(repeating: (0, 0, 0), count: 6)
        )
        let sample = GarmentColorSampler.sample(in: image, mask: mask)

        #expect(abs(sample.dominantColor.red - 200.0 / 255) < 0.01)
        #expect(abs(sample.dominantColor.green - 50.0 / 255) < 0.01)
        // Os 4 px de foreground são todos da mesma cor: 100% num bin.
        #expect(!sample.isPatterned)
    }

    @Test func samplingIsDeterministic() {
        let image = makeStripImage(
            Array(repeating: (255, 0, 0), count: 4)
                + Array(repeating: (0, 255, 0), count: 3)
                + Array(repeating: (0, 0, 255), count: 3)
        )
        #expect(
            GarmentColorSampler.sample(in: image, region: fullRegion)
                == GarmentColorSampler.sample(in: image, region: fullRegion)
        )
    }

    @Test func degenerateRegionReturnsBlackAndUnpatterned() {
        let image = makeStripImage(Array(repeating: (200, 50, 50), count: 10))
        let sample = GarmentColorSampler.sample(
            in: image, region: CGRect(x: 0, y: 0, width: 0, height: 0)
        )

        #expect(sample.dominantColor == ClosetColor(red: 0, green: 0, blue: 0))
        #expect(!sample.isPatterned)
    }

    @Test func maskWithNoForegroundReturnsBlackAndUnpatterned() {
        let image = makeStripImage(Array(repeating: (200, 50, 50), count: 10))
        let mask = makeStripImage(Array(repeating: (0, 0, 0), count: 10))
        let sample = GarmentColorSampler.sample(in: image, mask: mask)

        #expect(sample.dominantColor == ClosetColor(red: 0, green: 0, blue: 0))
        #expect(!sample.isPatterned)
    }
}
