import SwiftUI

/// Spacing scale: 4 · 8 · 12 · 16 · 20 · 24 · 32, plus the semantic values chosen in 0.1.
public nonisolated enum Spacing {
    public static let xxSmall: CGFloat = 4
    public static let xSmall: CGFloat = 8
    public static let small: CGFloat = 12
    public static let medium: CGFloat = 16
    public static let large: CGFloat = 20
    public static let xLarge: CGFloat = 24
    public static let xxLarge: CGFloat = 32

    /// Horizontal margin of a screen.
    public static let screenEdge = large
    /// Between parts of the day and other top-level sections.
    public static let section = xxLarge
    /// Between cards and rows in a list or grid.
    public static let cardGap = small
    /// Inside a card or row.
    public static let cardPadding = large

    public static let scale = [xxSmall, xSmall, small, medium, large, xLarge, xxLarge]
}

/// Corner radii. Always used with `.continuous` corners; see the shapes below.
public nonisolated enum Radius {
    public static let card: CGFloat = 28
    public static let row: CGFloat = 20
    public static let small: CGFloat = 12
}

/// Base sizes. Components scale them with Dynamic Type through `@ScaledMetric`.
public nonisolated enum Size {
    /// Round buttons: check, play.
    public static let button: CGFloat = 44
    /// Routine icon in a circle.
    public static let iconBadge: CGFloat = 40
    /// Exercise photo thumbnail.
    public static let thumbnail: CGFloat = 56
    public static let tileMinHeight: CGFloat = 132
    public static let progressBar: CGFloat = 8
}

public nonisolated enum Opacity {
    /// Completed tiles and rows.
    public static let completed = 0.6
    /// Fill behind a colored icon: the icon color at this opacity.
    public static let iconFill = 0.16
    /// Translucent fills on the accent: icon circles, the unchecked button on a filled row.
    public static let onAccentFill = 0.22
}

public nonisolated enum Stroke {
    /// Dashed outline of an empty slot — the only outline in the design.
    public static let dashed = StrokeStyle(lineWidth: 1.5, dash: [6, 5])
}

public extension Shape where Self == RoundedRectangle {
    nonisolated static var card: RoundedRectangle {
        RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
    }

    nonisolated static var row: RoundedRectangle {
        RoundedRectangle(cornerRadius: Radius.row, style: .continuous)
    }

    nonisolated static var small: RoundedRectangle {
        RoundedRectangle(cornerRadius: Radius.small, style: .continuous)
    }
}
