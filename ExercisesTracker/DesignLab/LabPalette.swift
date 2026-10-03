#if DEBUG
    import SwiftUI
    import UIKit

    // Temporary lab for task 0.1: colors come straight from the starting values in docs/DESIGN.md.
    // Direction A was chosen; the values move into the DesignSystem framework tokens (0.2) and this folder goes away.

    enum LabPalette {
        static let accent = Color(light: 0xF77F3C, dark: 0xFF8A4C)
        static let onAccent = Color(light: 0xFFFFFF, dark: 0xFFFFFF)
        static let background = Color(light: 0xFAF8F6, dark: 0x171514)
        static let surface = Color(light: 0xF0EDEA, dark: 0x262321)
        static let surfaceRaised = Color(light: 0xFFFFFF, dark: 0x302C2A)
        static let textPrimary = Color(light: 0x1A1716, dark: 0xF7F3F0)
        static let textSecondary = Color(light: 0x8A837E, dark: 0xA39B95)
        static let outline = Color(light: 0xD9D3CE, dark: 0x3D3835)

        static let morning = LabDayPartTint(
            background: Color(light: 0xFFE6D8, dark: 0x3D2A1F),
            icon: Color(light: 0xF77F3C, dark: 0xFF8A4C)
        )
        static let day = LabDayPartTint(
            background: Color(light: 0xFFF0CC, dark: 0x3A3120),
            icon: Color(light: 0xD99A1E, dark: 0xE8AE3A)
        )
        static let evening = LabDayPartTint(
            background: Color(light: 0xF3E3EC, dark: 0x352731),
            icon: Color(light: 0xA8577E, dark: 0xD58BB0)
        )

        static let coral = Color(light: 0xEE6A5A, dark: 0xF47E6F)
        static let amber = Color(light: 0xE09A2D, dark: 0xEBAE4A)
        static let sage = Color(light: 0x7E9C78, dark: 0x9DB897)
        static let plum = Color(light: 0x8E5B7E, dark: 0xB683A6)
    }

    struct LabDayPartTint {
        let background: Color
        let icon: Color
    }

    extension Color {
        /// `nonisolated` so the provider closure doesn't inherit MainActor: UIKit may resolve colors off the main
        /// thread.
        nonisolated init(light: UInt32, dark: UInt32) {
            self.init(uiColor: UIColor { traits in
                UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
            })
        }
    }

    private extension UIColor {
        nonisolated convenience init(hex: UInt32) {
            self.init(
                red: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: 1
            )
        }
    }
#endif
