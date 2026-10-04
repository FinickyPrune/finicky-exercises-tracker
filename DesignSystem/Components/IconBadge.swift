import SwiftUI

/// SF Symbol in a tinted circle: the icon of a routine. Decorative — hidden from VoiceOver.
struct IconBadge: View {
    let symbol: String
    let tint: ColorToken
    /// Drawn on an accent card: white icon on a translucent white circle.
    var onAccent = false

    @ScaledMetric(relativeTo: .headline) private var size = Size.iconBadge

    var body: some View {
        Image(systemName: symbol)
            .font(.body.weight(.semibold))
            .foregroundStyle(onAccent ? Palette.onAccent : tint)
            .frame(width: size, height: size)
            .background(fill, in: .circle)
            .accessibilityHidden(true)
    }

    private var fill: AnyShapeStyle {
        onAccent
            ? AnyShapeStyle(Palette.onAccent.opacity(Opacity.onAccentFill))
            : AnyShapeStyle(tint.opacity(Opacity.iconFill))
    }
}
