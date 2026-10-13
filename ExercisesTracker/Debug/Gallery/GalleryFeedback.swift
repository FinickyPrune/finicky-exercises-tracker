#if DEBUG
    import DesignSystem
    import SwiftUI

    /// Every feedback event with a button that plays it. Haptics only on a real iPhone.
    struct FeedbackSamples: View {
        @Binding var celebrating: Bool

        @State private var stepDone = false
        @State private var completions = 0
        @State private var undos = 0
        @State private var fact = 15
        @State private var routineDone = false
        @State private var routineFlashes = 0
        @State private var ticks = 0
        @State private var timerFinished = 0
        @State private var dayParts = 0

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.large) {
                row(.galleryFeedbackStep) {
                    AnimatedCheckmark(isOn: stepDone)
                        .foregroundStyle(Palette.accent)
                        .frame(width: Size.button, height: Size.button)
                        .background(Palette.surface, in: .circle)
                } play: {
                    stepDone.toggle()
                    if stepDone {
                        completions += 1
                    } else {
                        undos += 1
                    }
                }
                .feedback(.stepCompleted, trigger: completions)
                .feedback(.undone, trigger: undos)

                row(.galleryFeedbackFact) {
                    Text("\(fact)")
                        .font(.planNumber(.title2))
                        .contentTransition(.numericText(value: Double(fact)))
                        .feedbackAnimation(.factChanged, value: fact)
                } play: {
                    fact = fact == 15 ? 12 : 15
                }
                .feedback(.factChanged, trigger: fact)

                VStack(alignment: .leading, spacing: Spacing.small) {
                    row(.galleryFeedbackRoutine) {
                        EmptyView()
                    } play: {
                        routineDone.toggle()
                        if routineDone {
                            routineFlashes += 1
                        }
                    }
                    RoutineCard(
                        String(localized: .demoWorkout), status: .galleryProgress(routineDone ? 6 : 5, 6),
                        symbol: "figure.cooldown", tint: RoutineTint.orange.token,
                        state: routineDone ? .current : .pending
                    )
                    .completionFlash(trigger: routineFlashes)
                    .clipShape(.card)
                    .feedbackAnimation(.routineCompleted, value: routineDone)
                }
                .feedback(.routineCompleted, trigger: routineFlashes)

                row(.galleryFeedbackDayPart) {
                    Image(systemName: "sunrise.fill")
                        .font(.sectionTitle)
                        .foregroundStyle(DayPartTint.morning.icon)
                } play: {
                    dayParts += 1
                    celebrating = true
                }
                .feedback(.dayPartCompleted, trigger: dayParts)

                row(.galleryFeedbackTimerTick) {
                    Circle()
                        .stroke(Palette.accent, lineWidth: Spacing.xxSmall)
                        .frame(width: Size.button, height: Size.button)
                        .pulse(trigger: ticks)
                } play: {
                    ticks += 1
                }
                .feedback(.timerTick, trigger: ticks)

                row(.galleryFeedbackTimerDone) {
                    Circle()
                        .trim(from: 0, to: timerFinished.isMultiple(of: 2) ? 0.75 : 1)
                        .stroke(Palette.accent, style: StrokeStyle(lineWidth: Spacing.xxSmall, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: Size.button, height: Size.button)
                        .feedbackAnimation(.timerFinished, value: timerFinished)
                } play: {
                    timerFinished += 1
                }
                .feedback(.timerFinished, trigger: timerFinished)
            }
            .padding(.vertical, Spacing.xSmall)
        }

        private func row(
            _ title: LocalizedStringResource,
            @ViewBuilder sample: () -> some View,
            play: @escaping () -> Void
        ) -> some View {
            HStack(spacing: Spacing.small) {
                sample()
                Text(title)
                    .font(.itemStatus)
                    .frame(maxWidth: .infinity, alignment: .leading)
                CapsuleButton(.galleryPlay, style: .dark, action: play)
                    .fixedSize()
            }
        }
    }
#endif
