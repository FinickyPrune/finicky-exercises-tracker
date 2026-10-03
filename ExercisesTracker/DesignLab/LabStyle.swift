#if DEBUG
import SwiftUI

/// One visual direction under evaluation in task 0.1.
struct LabStyle: Identifiable {
    enum Highlight {
        /// The current routine or next exercise is filled with the accent color.
        case filledCard
        /// Neutral card; the primary action is an accent capsule button.
        case accentCapsule
    }

    enum TodayLayout {
        case grid
        case list
    }

    enum DayPartHeader {
        case section
        case capsule
    }

    let id: String
    let name: String
    let summary: String
    var titleDesign: Font.Design
    let highlight: Highlight
    let todayLayout: TodayLayout
    let dayPartHeader: DayPartHeader
    let sectionSpacing: CGFloat
    let rowSpacing: CGFloat
    let rowPadding: CGFloat

    var titleFont: Font {
        .system(.largeTitle, design: titleDesign, weight: .bold)
    }

    static let gentler = LabStyle(
        id: "a",
        name: "A · Gentler",
        summary: "Просторно, рутины сеткой, текущая залита акцентом",
        titleDesign: .default,
        highlight: .filledCard,
        todayLayout: .grid,
        dayPartHeader: .section,
        sectionSpacing: 32,
        rowSpacing: 12,
        rowPadding: 20
    )

    static let tiimo = LabStyle(
        id: "b",
        name: "B · Tiimo",
        summary: "Плотный список, капсулы частей дня, действие — акцентная капсула",
        titleDesign: .default,
        highlight: .accentCapsule,
        todayLayout: .list,
        dayPartHeader: .capsule,
        sectionSpacing: 24,
        rowSpacing: 8,
        rowPadding: 12
    )

    static let hybrid = LabStyle(
        id: "c",
        name: "C · Гибрид",
        summary: "Капсулы частей дня, текущая рутина — крупная акцентная карточка",
        titleDesign: .default,
        highlight: .filledCard,
        todayLayout: .list,
        dayPartHeader: .capsule,
        sectionSpacing: 28,
        rowSpacing: 10,
        rowPadding: 16
    )

    static let all = [gentler, tiimo, hybrid]
}

enum LabFont {
    static let sectionTitle = Font.system(.title3, weight: .bold)

    static func number(_ style: Font.TextStyle) -> Font {
        .system(style, design: .rounded, weight: .semibold)
    }
}

extension View {
    /// Uppercase caption with letter spacing: «2 ИЗ 4 · С 7:00».
    func labCaps() -> some View {
        font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .tracking(1)
    }
}
#endif
