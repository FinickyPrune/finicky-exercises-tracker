#if DEBUG
    import DesignSystem
    import SwiftUI

    /// Token name, its light and dark swatches and hex values; a third swatch when Increase Contrast differs.
    struct ColorTokenRow: View {
        let token: ColorToken

        var body: some View {
            HStack(spacing: Spacing.small) {
                Swatch(token: token, scheme: .light)
                Swatch(token: token, scheme: .dark)
                if token.lightIncreasedContrast != nil {
                    Swatch(token: token, scheme: .light, contrast: .increased)
                }
                VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                    Text(token.name)
                        .font(.itemTitle)
                    Text(hexLine)
                        .font(.caption.monospaced())
                        .foregroundStyle(Palette.textSecondary)
                }
            }
        }

        private var hexLine: String {
            var parts = [token.light, token.dark].map(\.hexString)
            if let increased = token.lightIncreasedContrast {
                parts.append("HC \(increased.hexString)")
            }
            return parts.joined(separator: " · ")
        }
    }

    private struct Swatch: View {
        let token: ColorToken
        let scheme: ColorScheme
        var contrast = ColorSchemeContrast.standard

        @ScaledMetric private var size = Size.iconBadge

        var body: some View {
            RoundedRectangle.small
                .fill(token.color(for: scheme, contrast: contrast))
                .frame(width: size, height: size)
                .overlay {
                    RoundedRectangle.small
                        .strokeBorder(Palette.outline, lineWidth: 1)
                }
                .accessibilityHidden(true)
        }
    }

    /// A foreground on a background with the minimum it has to meet.
    struct ContrastPair: Identifiable {
        let title: String
        let foreground: ColorToken
        let background: ColorToken
        let minimum: Double

        var id: String {
            title
        }

        func ratio(_ scheme: ColorScheme, _ contrast: ColorSchemeContrast = .standard) -> Double {
            Contrast.ratio(
                foreground.hex(for: scheme, contrast: contrast),
                background.hex(for: scheme, contrast: contrast)
            )
        }

        static let all = [
            ContrastPair(
                title: "Текст на фоне", foreground: Palette.textPrimary, background: Palette.background,
                minimum: Contrast.text
            ),
            ContrastPair(
                title: "Текст на карточке", foreground: Palette.textPrimary, background: Palette.surface,
                minimum: Contrast.text
            ),
            ContrastPair(
                title: "Подпись на карточке", foreground: Palette.textSecondary, background: Palette.surface,
                minimum: Contrast.text
            ),
            ContrastPair(
                title: "Белый на акценте", foreground: Palette.onAccent, background: Palette.accent,
                minimum: Contrast.large
            ),
            ContrastPair(
                title: "Галочка «по плану»", foreground: Palette.textSecondary, background: Palette.surfaceRaised,
                minimum: Contrast.large
            ),
            ContrastPair(
                title: "Акцент на фоне", foreground: Palette.accent, background: Palette.background,
                minimum: Contrast.large
            ),
        ]
    }

    struct ContrastPairRow: View {
        let pair: ContrastPair

        var body: some View {
            HStack {
                Text(pair.title)
                Spacer()
                Text(values)
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(Palette.textSecondary)
                Image(systemName: passes ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(passes ? Palette.textSecondary : Palette.accent)
                    .accessibilityLabel(passes ? "Проходит" : "Ниже минимума")
            }
        }

        private var ratios: [Double] {
            [pair.ratio(.light), pair.ratio(.dark), pair.ratio(.light, .increased)]
        }

        /// Warns when any of the three appearances is below the minimum.
        private var passes: Bool {
            ratios.allSatisfy { $0 >= pair.minimum }
        }

        private var values: String {
            ratios.map { $0.formatted(.number.precision(.fractionLength(1))) }.joined(separator: " · ")
        }
    }

    struct DayPartTintRow: View {
        let tint: DayPartTint

        var body: some View {
            HStack(spacing: Spacing.small) {
                ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
                    Image(systemName: symbol)
                        .foregroundStyle(tint.icon)
                        .padding(.horizontal, Spacing.medium)
                        .padding(.vertical, Spacing.xSmall)
                        .background(tint.background, in: .capsule)
                        .environment(\.colorScheme, scheme)
                }
                Text(tint.name)
                    .font(.itemTitle)
            }
        }

        private var symbol: String {
            switch tint {
            case .day: "sun.max.fill"
            case .evening: "moon.stars.fill"
            default: "sunrise.fill"
            }
        }
    }

    private extension UInt32 {
        var hexString: String {
            String(format: "#%06X", self)
        }
    }
#endif
