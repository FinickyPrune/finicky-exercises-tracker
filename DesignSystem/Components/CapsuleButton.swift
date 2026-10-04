import SwiftUI

/// Capsule-shaped button: accent for the main action, dark for finishing, light for an action on an accent card.
public struct CapsuleButton: View {
    public enum Style: Sendable {
        /// White title on the accent.
        case accent
        /// Background-colored title on the primary text color: «Завершить зарядку».
        case dark
        /// Accent title on `onAccent`, for a button that sits on an accent card.
        case onAccent
    }

    private let title: String
    private let style: Style
    private let fullWidth: Bool
    private let action: () -> Void

    @ScaledMetric(relativeTo: .subheadline) private var minHeight = Size.button

    public init(_ title: String, style: Style = .accent, fullWidth: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.fullWidth = fullWidth
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.buttonLabel)
                .foregroundStyle(foreground)
                .padding(.horizontal, Spacing.large)
                .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: minHeight)
                .background(background, in: .capsule)
                .contentShape(.capsule)
        }
        .buttonStyle(PressedStyle())
    }

    private var foreground: ColorToken {
        switch style {
        case .accent: Palette.onAccent
        case .dark: Palette.background
        case .onAccent: Palette.accent
        }
    }

    private var background: ColorToken {
        switch style {
        case .accent: Palette.accent
        case .dark: Palette.textPrimary
        case .onAccent: Palette.onAccent
        }
    }
}

/// Slight shrink while pressed.
private struct PressedStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.snappy, value: configuration.isPressed)
    }
}

#Preview("Стили") {
    VStack(spacing: Spacing.medium) {
        CapsuleButton("Продолжить") {}
        CapsuleButton("Завершить зарядку", style: .dark, fullWidth: true) {}
        CapsuleButton("Продолжить", style: .onAccent, fullWidth: true) {}
            .padding(Spacing.large)
            .background(Palette.accent, in: .card)
    }
    .padding(Spacing.screenEdge)
    .background(Palette.background)
}

#Preview("Тёмная") {
    VStack(spacing: Spacing.medium) {
        CapsuleButton("Продолжить") {}
        CapsuleButton("Завершить зарядку", style: .dark, fullWidth: true) {}
    }
    .padding(Spacing.screenEdge)
    .background(Palette.background)
    .preferredColorScheme(.dark)
}
