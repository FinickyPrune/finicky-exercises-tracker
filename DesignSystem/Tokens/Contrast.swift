import Foundation

/// WCAG 2 contrast ratio between two sRGB colors given as 0xRRGGBB.
public nonisolated enum Contrast {
    /// Minimum for normal text.
    public static let text = 4.5
    /// Minimum for large or bold text and for meaningful non-text marks (icons, checkmarks).
    public static let large = 3.0

    /// From 1 (same color) to 21 (black on white).
    public static func ratio(_ first: UInt32, _ second: UInt32) -> Double {
        let lighter = max(luminance(first), luminance(second))
        let darker = min(luminance(first), luminance(second))
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// Relative luminance, 0 for black and 1 for white.
    public static func luminance(_ hex: UInt32) -> Double {
        let red = linear((hex >> 16) & 0xFF)
        let green = linear((hex >> 8) & 0xFF)
        let blue = linear(hex & 0xFF)
        return 0.2126 * red + 0.7152 * green + 0.0722 * blue
    }

    private static func linear(_ channel: UInt32) -> Double {
        let value = Double(channel) / 255
        return value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
    }
}
