import Testing
import CoreGraphics
@testable import AcademyAI

struct ImageCropRectMapperTests {
    @Test func mapsFullContainerCropToFullImageWhenAspectRatiosMatch() {
        let result = ImageCropRectMapper.pixelRect(
            cropRect: CGRect(x: 0, y: 0, width: 200, height: 100),
            containerSize: CGSize(width: 200, height: 100),
            imageSize: CGSize(width: 400, height: 200)
        )
        #expect(result == CGRect(x: 0, y: 0, width: 400, height: 200))
    }

    @Test func mapsCenteredCropToProportionalImageRect() {
        let result = ImageCropRectMapper.pixelRect(
            cropRect: CGRect(x: 50, y: 25, width: 100, height: 50),
            containerSize: CGSize(width: 200, height: 100),
            imageSize: CGSize(width: 400, height: 200)
        )
        #expect(result == CGRect(x: 100, y: 50, width: 200, height: 100))
    }

    @Test func accountsForLetterboxingWhenImageIsNarrowerThanContainer() {
        let result = ImageCropRectMapper.pixelRect(
            cropRect: CGRect(x: 50, y: 0, width: 100, height: 100),
            containerSize: CGSize(width: 200, height: 100),
            imageSize: CGSize(width: 100, height: 100)
        )
        #expect(result == CGRect(x: 0, y: 0, width: 100, height: 100))
    }

    @Test func clampsCropRectThatExtendsPastImageBounds() {
        let result = ImageCropRectMapper.pixelRect(
            cropRect: CGRect(x: -20, y: -20, width: 300, height: 300),
            containerSize: CGSize(width: 200, height: 200),
            imageSize: CGSize(width: 200, height: 200)
        )
        #expect(result == CGRect(x: 0, y: 0, width: 200, height: 200))
    }
}
