@testable import DesignSystem
import SwiftUI
import Testing

struct ColorTokenTests {
    private let plain = ColorToken("plain", light: 0x111111, dark: 0x222222)
    private let contrasted = ColorToken(
        "contrasted",
        light: 0x111111,
        dark: 0x222222,
        lightIncreasedContrast: 0x333333,
        darkIncreasedContrast: 0x444444
    )

    @Test func picksValueByColorScheme() {
        #expect(plain.hex(for: .light) == 0x111111)
        #expect(plain.hex(for: .dark) == 0x222222)
    }

    @Test func increasedContrastFallsBackToRegularValue() {
        #expect(plain.hex(for: .light, contrast: .increased) == 0x111111)
        #expect(plain.hex(for: .dark, contrast: .increased) == 0x222222)
    }

    @Test func increasedContrastUsesItsOwnValue() {
        #expect(contrasted.hex(for: .light, contrast: .increased) == 0x333333)
        #expect(contrasted.hex(for: .dark, contrast: .increased) == 0x444444)
        #expect(contrasted.hex(for: .light) == 0x111111)
    }
}
