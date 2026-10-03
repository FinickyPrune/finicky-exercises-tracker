#if DEBUG
import SwiftUI

struct LabWorkoutView: View {
    let style: LabStyle

    @State private var exercises = LabDemo.exercises
    @State private var completions = 0

    private var doneCount: Int {
        exercises.filter(\.isDone).count
    }

    private var nextID: String? {
        exercises.first { !$0.isDone }?.id
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: style.rowSpacing) {
                header
                    .padding(.bottom, style.rowSpacing + 8)
                ForEach($exercises) { $exercise in
                    LabExerciseRow(exercise: exercise, isNext: exercise.id == nextID, style: style) {
                        withAnimation(.snappy) { exercise.isDone.toggle() }
                        if exercise.isDone { completions += 1 }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(LabPalette.background)
        .safeAreaInset(edge: .bottom) {
            LabCapsuleButton(title: "Завершить зарядку", kind: .dark, fullWidth: true) {}
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
        }
        .sensoryFeedback(.success, trigger: completions)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Утро · 6 упражнений")
                .labCaps()
                .foregroundStyle(LabPalette.textSecondary)
            Text("Зарядка")
                .font(style.titleFont)
                .foregroundStyle(LabPalette.textPrimary)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(doneCount)")
                    .font(LabFont.number(.title))
                    .foregroundStyle(LabPalette.textPrimary)
                    .contentTransition(.numericText())
                Text("из \(exercises.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(LabPalette.textSecondary)
            }
            LabProgressBar(value: Double(doneCount) / Double(exercises.count))
        }
    }
}

struct LabExerciseRow: View {
    let exercise: LabExercise
    let isNext: Bool
    let style: LabStyle
    let toggle: () -> Void

    @ScaledMetric private var thumbnail = 56.0

    private var filled: Bool {
        isNext && style.highlight == .filledCard
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: exercise.symbol)
                .font(.title2)
                .foregroundStyle(filled ? LabPalette.onAccent : exercise.tint)
                .frame(width: thumbnail, height: thumbnail)
                .background(
                    filled ? LabPalette.onAccent.opacity(0.22) : exercise.tint.opacity(0.14),
                    in: .rect(cornerRadius: 12, style: .continuous)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.headline)
                LabPlanText(plan: exercise.plan, size: isNext ? .title2 : .title3)
                if let note = exercise.factNote {
                    Text(note)
                        .labCaps()
                        .foregroundStyle(filled ? LabPalette.onAccent : LabPalette.accent)
                }
            }
            .foregroundStyle(filled ? LabPalette.onAccent : LabPalette.textPrimary)
            .opacity(exercise.isDone ? 0.5 : 1)
            Spacer(minLength: 8)
            actions
        }
        .padding(style.rowPadding)
        .background(filled ? LabPalette.accent : LabPalette.surface,
                    in: .rect(cornerRadius: 20, style: .continuous))
    }

    /// In the capsule variant the next exercise's primary action is painted with the accent.
    private var accentAction: Bool {
        isNext && style.highlight == .accentCapsule
    }

    @ViewBuilder private var actions: some View {
        if exercise.plan.isTimed, !exercise.isDone {
            Button("Таймер", systemImage: "play.fill") {}
                .labelStyle(.iconOnly)
                .font(.body.weight(.bold))
                .foregroundStyle(playForeground)
                .frame(width: 44, height: 44)
                .background(playBackground, in: .circle)
                .buttonStyle(.plain)
        }
        if accentAction, !exercise.plan.isTimed {
            LabCapsuleButton(title: "По плану", action: toggle)
        } else {
            LabCheckButton(isOn: exercise.isDone, onAccent: filled, action: toggle)
        }
    }

    private var playForeground: Color {
        if filled { return LabPalette.accent }
        return accentAction ? LabPalette.onAccent : LabPalette.textPrimary
    }

    private var playBackground: Color {
        if filled { return LabPalette.onAccent }
        return accentAction ? LabPalette.accent : LabPalette.surfaceRaised
    }
}

#Preview("A") {
    NavigationStack { LabWorkoutView(style: .gentler) }
}

#Preview("B") {
    NavigationStack { LabWorkoutView(style: .tiimo) }
}

#Preview("C") {
    NavigationStack { LabWorkoutView(style: .hybrid) }
}
#endif
