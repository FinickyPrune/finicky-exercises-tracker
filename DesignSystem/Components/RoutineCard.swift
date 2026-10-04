import SwiftUI

/// Routine tile for the two-column grid on «Сегодня».
///
/// The card is not a button: wrap it in a `NavigationLink` or `Button` at the call site,
/// so the whole tile is one tap target and nothing inside it competes for the tap.
public struct RoutineCard: View {
    public enum Phase: Hashable, Sendable {
        /// Not done yet.
        case pending
        /// The routine to do now: filled with the accent.
        case current
        /// Done: dimmed, with a checkmark.
        case done
    }

    private let title: String
    private let status: String
    private let symbol: String
    private let tint: ColorToken
    private let state: Phase

    @ScaledMetric(relativeTo: .headline) private var minHeight = Size.tileMinHeight

    /// - Parameter status: second line, e.g. «2 из 6», «Откроет Journal», «Готово».
    public init(_ title: String, status: String, symbol: String, tint: ColorToken, state: Phase) {
        self.title = title
        self.status = status
        self.symbol = symbol
        self.tint = tint
        self.state = state
    }

    private var filled: Bool {
        state == .current
    }

    private var dimmed: Double {
        state == .done ? Opacity.completed : 1
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack(alignment: .top) {
                IconBadge(symbol: symbol, tint: tint, onAccent: filled)
                    .opacity(dimmed)
                Spacer(minLength: 0)
                if state == .done {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Palette.accent)
                }
            }
            Spacer(minLength: 0)
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                Text(title)
                    .font(.itemTitle)
                    .foregroundStyle(filled ? Palette.onAccent : Palette.textPrimary)
                    .opacity(dimmed)
                // The status is not dimmed: it is already secondary and would drop below readable contrast.
                Text(status)
                    .font(.itemStatus)
                    .foregroundStyle(filled ? Palette.onAccent : Palette.textSecondary)
            }
        }
        // Minimum height of the content; the padding comes on top (tile ≥ 132 + 2 × 20).
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
        .padding(Spacing.cardPadding)
        .background(filled ? Palette.accent : Palette.surface, in: .card)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(Self.accessibilityValue(state: state, status: status))
    }

    nonisolated static func accessibilityValue(state: Phase, status: String) -> String {
        switch state {
        case .pending: status
        case .current: "Сейчас, \(status)"
        case .done: "Выполнено, \(status)"
        }
    }
}

/// Grid of `RoutineCard`s: two columns, one column at accessibility text sizes.
/// Tiles in a row keep their own height; the shared minimum height keeps one-line titles even.
public struct RoutineGrid<Content: View>: View {
    private let content: Content

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        let columns = Array(
            repeating: GridItem(.flexible(), spacing: Spacing.cardGap, alignment: .top),
            count: Self.columnCount(for: dynamicTypeSize)
        )
        LazyVGrid(columns: columns, spacing: Spacing.cardGap) {
            content
        }
    }

    nonisolated static func columnCount(for size: DynamicTypeSize) -> Int {
        size.isAccessibilitySize ? 1 : 2
    }
}

#Preview("Состояния") {
    ScrollView {
        RoutineGrid {
            RoutineCard("Зарядка", status: "2 из 6", symbol: "figure.cooldown", tint: Palette.accent, state: .current)
            RoutineCard("Duolingo", status: "в 7:40", symbol: "bird.fill", tint: RoutineTint.sage.token, state: .done)
            RoutineCard(
                "Дневник", status: "Откроет Journal", symbol: "book.closed.fill", tint: RoutineTint.plum.token,
                state: .pending
            )
            RoutineCard(
                "Витамины", status: "Отметить", symbol: "pills.fill", tint: RoutineTint.amber.token, state: .pending
            )
        }
        .padding(Spacing.screenEdge)
    }
    .background(Palette.background)
}

#Preview("Тёмная") {
    RoutineGrid {
        RoutineCard("Зарядка", status: "2 из 6", symbol: "figure.cooldown", tint: Palette.accent, state: .current)
        RoutineCard("Duolingo", status: "в 7:40", symbol: "bird.fill", tint: RoutineTint.sage.token, state: .done)
        RoutineCard(
            "Витамины", status: "Отметить", symbol: "pills.fill", tint: RoutineTint.amber.token, state: .pending
        )
    }
    .padding(Spacing.screenEdge)
    .background(Palette.background)
    .preferredColorScheme(.dark)
}

#Preview("Крупный шрифт") {
    ScrollView {
        RoutineGrid {
            RoutineCard("Зарядка", status: "2 из 6", symbol: "figure.cooldown", tint: Palette.accent, state: .current)
            RoutineCard("Duolingo", status: "в 7:40", symbol: "bird.fill", tint: RoutineTint.sage.token, state: .done)
            RoutineCard(
                "Витамины", status: "Отметить", symbol: "pills.fill", tint: RoutineTint.amber.token, state: .pending
            )
        }
        .padding(Spacing.screenEdge)
    }
    .background(Palette.background)
    .dynamicTypeSize(.accessibility2)
}

#Preview("Крупный шрифт, тёмная") {
    ScrollView {
        RoutineGrid {
            RoutineCard("Зарядка", status: "2 из 6", symbol: "figure.cooldown", tint: Palette.accent, state: .current)
            RoutineCard("Duolingo", status: "в 7:40", symbol: "bird.fill", tint: RoutineTint.sage.token, state: .done)
        }
        .padding(Spacing.screenEdge)
    }
    .background(Palette.background)
    .dynamicTypeSize(.accessibility2)
    .preferredColorScheme(.dark)
}
