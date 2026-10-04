#if DEBUG
    import DesignSystem
    import SwiftUI

    struct HeaderSamples: View {
        @State private var morningCollapsed = false

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.xLarge) {
                DayPartHeader(
                    "Утро", subtitle: "1 из 4 · с 7:00", symbol: "sunrise.fill", tint: .morning,
                    isCollapsed: $morningCollapsed
                )
                VStack(alignment: .leading, spacing: Spacing.small) {
                    DayPartHeader("День", subtitle: "с 12:00", symbol: "sun.max.fill", tint: .day)
                    EmptySlot("Что сегодня днём?") {}
                }
                DayPartHeader(
                    "Вечер", subtitle: "0 из 1 · с 20:00", symbol: "moon.stars.fill", tint: .evening,
                    isCollapsed: .constant(true)
                )
            }
            .padding(.vertical, Spacing.xSmall)
        }
    }

    struct CardSamples: View {
        var body: some View {
            RoutineGrid {
                RoutineCard(
                    "Зарядка", status: "2 из 6", symbol: "figure.cooldown", tint: RoutineTint.orange.token,
                    state: .current
                )
                RoutineCard(
                    "Duolingo", status: "в 7:40", symbol: "bird.fill", tint: RoutineTint.sage.token, state: .done
                )
                RoutineCard(
                    "Дневник", status: "Откроет Journal", symbol: "book.closed.fill", tint: RoutineTint.plum.token,
                    state: .pending
                )
                RoutineCard(
                    "Витамины", status: "Отметить", symbol: "pills.fill", tint: RoutineTint.amber.token,
                    state: .pending
                )
            }
            .padding(.vertical, Spacing.xSmall)
        }
    }

    struct ControlSamples: View {
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                VStack(alignment: .leading, spacing: Spacing.xSmall) {
                    PlanBadge(sets: 3, amount: .reps(15))
                    PlanBadge(sets: 3, amount: .duration(seconds: 30))
                    PlanBadge(sets: 1, amount: .duration(seconds: 90), size: .title2)
                }
                .foregroundStyle(Palette.textPrimary)
                HStack(spacing: Spacing.small) {
                    CapsuleButton("Продолжить") {}
                    CapsuleButton("Готово", style: .dark) {}
                }
                CapsuleButton("Продолжить", style: .onAccent, fullWidth: true) {}
                    .padding(Spacing.large)
                    .background(Palette.accent, in: .card)
                CapsuleButton("Завершить зарядку", style: .dark, fullWidth: true) {}
            }
            .padding(.vertical, Spacing.xSmall)
        }
    }
#endif
