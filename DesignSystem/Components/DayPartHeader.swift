import SwiftUI

/// Header of a part of the day: icon in the part's color, bold title, caps subtitle and an optional collapse chevron.
public struct DayPartHeader: View {
    private let title: String
    private let subtitle: LocalizedStringResource
    private let symbol: String
    private let tint: DayPartTint
    private let isCollapsed: Binding<Bool>?

    @ScaledMetric(relativeTo: .title3) private var chevronSize = Size.button

    /// - Parameters:
    ///   - title: the part of the day's name, shown as it is.
    ///   - subtitle: progress and start time, e.g. «1 of 4 · from 7:00». Shown in caps.
    ///   - isCollapsed: pass a binding to show the collapse chevron; `nil` hides it.
    public init(
        _ title: String,
        subtitle: LocalizedStringResource,
        symbol: String,
        tint: DayPartTint,
        isCollapsed: Binding<Bool>? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.symbol = symbol
        self.tint = tint
        self.isCollapsed = isCollapsed
    }

    public var body: some View {
        HStack(alignment: .center, spacing: Spacing.small) {
            Image(systemName: symbol)
                .font(.sectionTitle)
                .foregroundStyle(tint.icon)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                Text(title)
                    .font(.sectionTitle)
                    .foregroundStyle(Palette.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text(subtitle)
                    .capsLabel()
                    .foregroundStyle(Palette.textSecondary)
            }
            .accessibilityElement(children: .combine)
            Spacer(minLength: 0)
            if let isCollapsed {
                Button {
                    withAnimation(.snappy) { isCollapsed.wrappedValue.toggle() }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Palette.textSecondary)
                        .rotationEffect(.degrees(isCollapsed.wrappedValue ? -90 : 0))
                        .frame(width: chevronSize, height: chevronSize)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(isCollapsed.wrappedValue ? .dayPartExpand(title) : .dayPartCollapse(title)))
            }
        }
    }
}

#Preview("States") {
    @Previewable @State var collapsed = false
    VStack(alignment: .leading, spacing: Spacing.section) {
        DayPartHeader(
            String(localized: .previewMorning), subtitle: .previewProgressFrom(1, 4, "7:00"), symbol: "sunrise.fill",
            tint: .morning, isCollapsed: $collapsed
        )
        DayPartHeader(
            String(localized: .previewDay), subtitle: .previewFrom("12:00"), symbol: "sun.max.fill", tint: .day
        )
        DayPartHeader(
            String(localized: .previewEvening), subtitle: .previewProgressFrom(1, 1, "20:00"),
            symbol: "moon.stars.fill", tint: .evening, isCollapsed: .constant(true)
        )
    }
    .padding(Spacing.screenEdge)
    .background(Palette.background)
}

#Preview("Dark") {
    VStack(alignment: .leading, spacing: Spacing.section) {
        DayPartHeader(
            String(localized: .previewMorning), subtitle: .previewProgressFrom(1, 4, "7:00"), symbol: "sunrise.fill",
            tint: .morning, isCollapsed: .constant(false)
        )
        DayPartHeader(
            String(localized: .previewDay), subtitle: .previewFrom("12:00"), symbol: "sun.max.fill", tint: .day
        )
        DayPartHeader(
            String(localized: .previewEvening), subtitle: .previewProgressFrom(1, 1, "20:00"),
            symbol: "moon.stars.fill", tint: .evening, isCollapsed: .constant(true)
        )
    }
    .padding(Spacing.screenEdge)
    .background(Palette.background)
    .preferredColorScheme(.dark)
}

#Preview("Large text") {
    DayPartHeader(
        String(localized: .previewMorning), subtitle: .previewProgressFrom(1, 4, "7:00"), symbol: "sunrise.fill",
        tint: .morning, isCollapsed: .constant(false)
    )
    .padding(Spacing.screenEdge)
    .background(Palette.background)
    .dynamicTypeSize(.accessibility2)
}
