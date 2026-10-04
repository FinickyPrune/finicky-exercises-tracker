import SwiftUI

/// A named color with values for light and dark appearance and, optionally, for Increase Contrast.
///
/// Use it anywhere SwiftUI takes a `ShapeStyle`: `.foregroundStyle(Palette.accent)`,
/// `.background(Palette.surface, in: .card)`. It resolves from the environment, so it follows the
/// color scheme and contrast of the view it is drawn in, and it is safe to resolve off the main thread.
nonisolated public struct ColorToken: ShapeStyle, Hashable, Identifiable {
    public let name: String
    public let light: UInt32
    public let dark: UInt32
    public let lightIncreasedContrast: UInt32?
    public let darkIncreasedContrast: UInt32?

    public var id: String {
        name
    }

    public init(
        _ name: String,
        light: UInt32,
        dark: UInt32,
        lightIncreasedContrast: UInt32? = nil,
        darkIncreasedContrast: UInt32? = nil
    ) {
        self.name = name
        self.light = light
        self.dark = dark
        self.lightIncreasedContrast = lightIncreasedContrast
        self.darkIncreasedContrast = darkIncreasedContrast
    }

    /// The same values under another name, for tokens defined as "equal to" another one.
    public func named(_ name: String) -> ColorToken {
        ColorToken(
            name,
            light: light,
            dark: dark,
            lightIncreasedContrast: lightIncreasedContrast,
            darkIncreasedContrast: darkIncreasedContrast
        )
    }

    /// The 0xRRGGBB value used for a given appearance.
    public func hex(for scheme: ColorScheme, contrast: ColorSchemeContrast = .standard) -> UInt32 {
        switch (scheme, contrast) {
        case (.dark, .increased): darkIncreasedContrast ?? dark
        case (.dark, _): dark
        case (_, .increased): lightIncreasedContrast ?? light
        default: light
        }
    }

    /// The color for a given appearance, regardless of the environment. For catalogs and previews.
    public func color(for scheme: ColorScheme, contrast: ColorSchemeContrast = .standard) -> Color {
        Color(hex: hex(for: scheme, contrast: contrast))
    }

    public func resolve(in environment: EnvironmentValues) -> Color {
        color(for: environment.colorScheme, contrast: environment.colorSchemeContrast)
    }
}

nonisolated extension Color {
    /// Color from a 0xRRGGBB value in sRGB.
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
