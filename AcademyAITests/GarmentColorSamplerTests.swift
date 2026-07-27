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
    @Test func solidGarmentReturnsItsColor() {
        let image = makeStripImage(Array(repeating: (200, 50, 50), count: 10))
        let color = GarmentColorSampler.dominantColor(in: image, region: fullRegion)

        #expect(abs(color.red - 200.0 / 255) < 0.01)
        #expect(abs(color.green - 50.0 / 255) < 0.01)
        #expect(abs(color.blue - 50.0 / 255) < 0.01)
    }

    // Duas tonalidades da mesma cor caem no mesmo bin, então a cor devolvida é
    // a média das duas — sombra não parte uma peça lisa em cores diferentes.
    @Test func shadingWithinOneBinAveragesToOneColor() {
        let image = makeStripImage(
            Array(repeating: (200, 50, 50), count: 5) + Array(repeating: (210, 55, 58), count: 5)
        )
        let color = GarmentColorSampler.dominantColor(in: image, region: fullRegion)

        #expect(abs(color.red - 205.0 / 255) < 0.01)
    }

    // O teste que prova que a moda substituiu a média: com três cores em partes
    // desiguais, o resultado é a cor mais frequente — nunca a média das três,
    // que seria um cinza que não existe na peça.
    @Test func threeColorGarmentReturnsTheMostFrequentColor() {
        let image = makeStripImage(
            Array(repeating: (255, 0, 0), count: 4)
                + Array(repeating: (0, 255, 0), count: 3)
                + Array(repeating: (0, 0, 255), count: 3)
        )
        let color = GarmentColorSampler.dominantColor(in: image, region: fullRegion)

        #expect(abs(color.red - 1.0) < 0.01)
        #expect(abs(color.green - 0.0) < 0.01)
        #expect(abs(color.blue - 0.0) < 0.01)
    }

    @Test func maskExcludesBackgroundFromTheColor() {
        // 4 px de peça vermelha, 6 px de fundo verde. Sem máscara o verde venceria.
        let image = makeStripImage(
            Array(repeating: (200, 50, 50), count: 4) + Array(repeating: (0, 255, 0), count: 6)
        )
        let mask = makeStripImage(
            Array(repeating: (255, 255, 255), count: 4) + Array(repeating: (0, 0, 0), count: 6)
        )
        let color = GarmentColorSampler.dominantColor(in: image, mask: mask)

        #expect(abs(color.red - 200.0 / 255) < 0.01)
        #expect(abs(color.green - 50.0 / 255) < 0.01)
    }

    @Test func samplingIsDeterministic() {
        let image = makeStripImage(
            Array(repeating: (255, 0, 0), count: 4)
                + Array(repeating: (0, 255, 0), count: 3)
                + Array(repeating: (0, 0, 255), count: 3)
        )
        #expect(
            GarmentColorSampler.dominantColor(in: image, region: fullRegion)
                == GarmentColorSampler.dominantColor(in: image, region: fullRegion)
        )
    }

    @Test func degenerateRegionReturnsBlack() {
        let image = makeStripImage(Array(repeating: (200, 50, 50), count: 10))
        let color = GarmentColorSampler.dominantColor(
            in: image, region: CGRect(x: 0, y: 0, width: 0, height: 0)
        )

        #expect(color == ClosetColor(red: 0, green: 0, blue: 0))
    }

    @Test func maskWithNoForegroundReturnsBlack() {
        let image = makeStripImage(Array(repeating: (200, 50, 50), count: 10))
        let mask = makeStripImage(Array(repeating: (0, 0, 0), count: 10))
        let color = GarmentColorSampler.dominantColor(in: image, mask: mask)

        #expect(color == ClosetColor(red: 0, green: 0, blue: 0))
    }
}
