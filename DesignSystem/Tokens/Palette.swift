import SwiftUI

/// App colors. Values and usage are documented in docs/DESIGN.md → Токены → Цвета.
nonisolated public enum Palette {
    /// Action and completion. White text on it is 2.6:1, so Increase Contrast darkens it to 4.7:1.
    public static let accent = ColorToken(
        "accent",
        light: 0xF77F3C,
        dark: 0xFF8A4C,
        lightIncreasedContrast: 0xBF5219,
        darkIncreasedContrast: 0xBF5219
    )
    public static let onAccent = ColorToken("onAccent", light: 0xFFFFFF, dark: 0xFFFFFF)
    public static let background = ColorToken("background", light: 0xFAF8F6, dark: 0x171514)
    public static let surface = ColorToken("surface", light: 0xF0EDEA, dark: 0x262321)
    public static let surfaceRaised = ColorToken("surfaceRaised", light: 0xFFFFFF, dark: 0x302C2A)
    public static let textPrimary = ColorToken("textPrimary", light: 0x1A1716, dark: 0xF7F3F0)
    /// 3.2:1 on `surface` in light appearance; Increase Contrast brings it to 5:1.
    public static let textSecondary = ColorToken(
        "textSecondary",
        light: 0x8A837E,
        dark: 0xA39B95,
        lightIncreasedContrast: 0x6B645F
    )
    public static let outline = ColorToken("outline", light: 0xD9D3CE, dark: 0x3D3835)

    /// Every base token, in the order the gallery shows them.
    public static let all = [
        accent, onAccent, background, surface, surfaceRaised, textPrimary, textSecondary, outline,
    ]
}

/// Background and icon color of a part of the day.
nonisolated public struct DayPartTint: Hashable, Sendable {
    public let name: String
    public let background: ColorToken
    public let icon: ColorToken

    public static let morning = DayPartTint(
        name: "morning",
        background: ColorToken("morning.background", light: 0xFFE6D8, dark: 0x3D2A1F),
        icon: ColorToken("morning.icon", light: 0xF77F3C, dark: 0xFF8A4C)
    )
    public static let day = DayPartTint(
        name: "day",
        background: ColorToken("day.background", light: 0xFFF0CC, dark: 0x3A3120),
        icon: ColorToken("day.icon", light: 0xD99A1E, dark: 0xE8AE3A)
    )
    public static let evening = DayPartTint(
        name: "evening",
        background: ColorToken("evening.background", light: 0xF3E3EC, dark: 0x352731),
        icon: ColorToken("evening.icon", light: 0xA8577E, dark: 0xD58BB0)
    )

    public static let all = [morning, day, evening]
}

/// Color a routine is drawn with; picked in the editor. The raw value is what gets stored.
nonisolated public enum RoutineTint: String, CaseIterable, Sendable {
    case orange
    case coral
    case amber
    case terracotta
    case pink
    case plum
    case sage
    case sand

    public var token: ColorToken {
        switch self {
        case .orange: ColorToken("orange", light: Palette.accent.light, dark: Palette.accent.dark)
        case .coral: ColorToken("coral", light: 0xEE6A5A, dark: 0xF47E6F)
        case .amber: ColorToken("amber", light: 0xE09A2D, dark: 0xEBAE4A)
        case .terracotta: ColorToken("terracotta", light: 0xC2603C, dark: 0xD97A55)
        case .pink: ColorToken("pink", light: 0xD9658A, dark: 0xE889A6)
        case .plum: ColorToken("plum", light: 0x8E5B7E, dark: 0xB683A6)
        case .sage: ColorToken("sage", light: 0x7E9C78, dark: 0x9DB897)
        case .sand: ColorToken("sand", light: 0xBF9A62, dark: 0xD2B27F)
        }
    }
}
