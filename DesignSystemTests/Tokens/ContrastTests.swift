@testable import DesignSystem
import Testing

struct ContrastTests {
    @Test func blackOnWhiteIsTwentyOne() {
        #expect(abs(Contrast.ratio(0x000000, 0xFFFFFF) - 21) < 0.001)
    }

    @Test func sameColorIsOne() {
        #expect(Contrast.ratio(0xF77F3C, 0xF77F3C) == 1)
    }

    @Test func orderDoesNotMatter() {
        #expect(Contrast.ratio(0x1A1716, 0xFAF8F6) == Contrast.ratio(0xFAF8F6, 0x1A1716))
    }

    @Test(arguments: [(UInt32(0x000000), 0.0), (0xFFFFFF, 1.0)])
    func luminanceSpansZeroToOne(hex: UInt32, expected: Double) {
        #expect(abs(Contrast.luminance(hex) - expected) < 0.000_1)
    }

    /// Matches the value recorded in docs/DESIGN.md for white on the accent.
    @Test func whiteOnAccentIsAboutTwoPointSix() {
        #expect(abs(Contrast.ratio(0xFFFFFF, 0xF77F3C) - 2.61) < 0.01)
    }
}
