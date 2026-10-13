#if DEBUG
    import DesignSystem
    import SwiftUI

    struct HeaderSamples: View {
        @State private var morningCollapsed = false

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.xLarge) {
                DayPartHeader(
                    String(localized: .demoMorning), subtitle: .galleryProgressFrom(1, 4, "7:00"),
                    symbol: "sunrise.fill", tint: .morning, isCollapsed: $morningCollapsed
                )
                VStack(alignment: .leading, spacing: Spacing.small) {
                    DayPartHeader(
                        String(localized: .demoDay), subtitle: .galleryFrom("12:00"), symbol: "sun.max.fill",
                        tint: .day
                    )
                    EmptySlot(.galleryDayPrompt) {}
                }
                DayPartHeader(
                    String(localized: .demoEvening), subtitle: .galleryProgressFrom(0, 1, "20:00"),
                    symbol: "moon.stars.fill", tint: .evening, isCollapsed: .constant(true)
                )
            }
            .padding(.vertical, Spacing.xSmall)
        }
    }

    struct CardSamples: View {
        var body: some View {
            RoutineGrid {
                RoutineCard(
                    String(localized: .demoWorkout), status: .galleryProgress(2, 6), symbol: "figure.cooldown",
                    tint: RoutineTint.orange.token, state: .current
                )
                RoutineCard(
                    String(localized: .demoDuolingo), status: .galleryAt("7:40"), symbol: "bird.fill",
                    tint: RoutineTint.sage.token, state: .done
                )
                RoutineCard(
                    String(localized: .demoJournal), status: .galleryOpensJournal, symbol: "book.closed.fill",
                    tint: RoutineTint.plum.token, state: .pending
                )
                RoutineCard(
                    String(localized: .demoVitamins), status: .galleryCheckOff, symbol: "pills.fill",
                    tint: RoutineTint.amber.token, state: .pending
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
                    CapsuleButton(.galleryContinue) {}
                    CapsuleButton(.galleryDone, style: .dark) {}
                }
                CapsuleButton(.galleryContinue, style: .onAccent, fullWidth: true) {}
                    .padding(Spacing.large)
                    .background(Palette.accent, in: .card)
                CapsuleButton(.galleryFinishWorkout, style: .dark, fullWidth: true) {}
            }
            .padding(.vertical, Spacing.xSmall)
        }
    }
#endif
