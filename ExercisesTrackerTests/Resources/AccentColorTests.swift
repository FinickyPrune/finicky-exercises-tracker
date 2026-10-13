import DesignSystem
@testable import ExercisesTracker
import SwiftUI
import Testing
import UIKit

/// The asset catalog's `AccentColor` is the app-wide default accent, also where SwiftUI's `.tint` does not reach.
/// Its values are a copy of `Palette.accent`, so they must stay equal.
struct AccentColorTests {
    @Test(arguments: [
        (ColorScheme.light, ColorSchemeContrast.standard),
        (ColorScheme.dark, ColorSchemeContrast.standard),
        (ColorScheme.light, ColorSchemeContrast.increased),
        (ColorScheme.dark, ColorSchemeContrast.increased),
    ])
    func assetMatchesPaletteAccent(scheme: ColorScheme, contrast: ColorSchemeContrast) throws {
        let asset = try #require(UIColor(named: "AccentColor"))
        let traits = UITraitCollection { traits in
            traits.userInterfaceStyle = scheme == .dark ? .dark : .light
            traits.accessibilityContrast = contrast == .increased ? .high : .normal
        }

        let actual = try Self.hex(of: asset.resolvedColor(with: traits))
        let expected = Palette.accent.hex(for: scheme, contrast: contrast)

        #expect(
            actual == expected,
            "AccentColor is #\(String(actual, radix: 16)), Palette.accent is #\(String(expected, radix: 16))"
        )
    }

    private static func hex(of color: UIColor) throws -> UInt32 {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        try #require(color.getRed(&red, green: &green, blue: &blue, alpha: &alpha))
        let byte = { (component: CGFloat) in UInt32((component * 255).rounded()) }
        return byte(red) << 16 | byte(green) << 8 | byte(blue)
    }
}
