#if DEBUG
    import SwiftUI

    /// Variant A: a tile in a two-column grid; the current routine is filled with the accent.
    struct LabRoutineTile: View {
        let routine: LabRoutine
        let style: LabStyle

        private var filled: Bool {
            routine.isCurrent && style.highlight == .filledCard
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    LabIconBadge(symbol: routine.symbol, tint: routine.tint, onAccent: filled)
                    Spacer()
                    if routine.isDone {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(LabPalette.accent)
                    }
                }
                Spacer(minLength: 0)
                Text(routine.name)
                    .font(.headline)
                    .foregroundStyle(filled ? LabPalette.onAccent : LabPalette.textPrimary)
                Text(routine.status)
                    .font(.subheadline)
                    .foregroundStyle(filled ? LabPalette.onAccent.opacity(0.85) : LabPalette.textSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .leading)
            .padding(style.rowPadding)
            .background(
                filled ? LabPalette.accent : LabPalette.surface,
                in: .rect(cornerRadius: 28, style: .continuous)
            )
            .opacity(routine.isDone ? 0.6 : 1)
        }
    }

    /// Variants B and C: a list row with the action on the trailing edge.
    struct LabRoutineRow: View {
        let routine: LabRoutine
        let style: LabStyle

        var body: some View {
            HStack(spacing: 12) {
                LabIconBadge(symbol: routine.symbol, tint: routine.tint)
                VStack(alignment: .leading, spacing: 2) {
                    Text(routine.name)
                        .font(.headline)
                        .foregroundStyle(LabPalette.textPrimary)
                        .strikethrough(routine.isDone, color: LabPalette.textSecondary)
                    Text(routine.status)
                        .font(.subheadline)
                        .foregroundStyle(LabPalette.textSecondary)
                }
                Spacer(minLength: 8)
                trailing
            }
            .padding(style.rowPadding)
            .background(LabPalette.surface, in: .rect(cornerRadius: 20, style: .continuous))
            .opacity(routine.isDone ? 0.6 : 1)
        }

        @ViewBuilder private var trailing: some View {
            if routine.isDone {
                LabCheckButton(isOn: true) {}
            } else if routine.isCurrent {
                LabCapsuleButton(title: "Продолжить") {}
            } else {
                switch routine.kind {
                case .link:
                    Image(systemName: "arrow.up.forward")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(LabPalette.textSecondary)
                        .frame(width: 44, height: 44)
                case .check, .steps:
                    LabCheckButton(isOn: false) {}
                }
            }
        }
    }

    /// Variant C: the current routine as a large accent card.
    struct LabRoutineHero: View {
        let routine: LabRoutine

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    LabIconBadge(symbol: routine.symbol, tint: routine.tint, onAccent: true)
                    Spacer()
                    Text("Сейчас")
                        .labCaps()
                        .foregroundStyle(LabPalette.onAccent.opacity(0.85))
                }
                Text(routine.name)
                    .font(.title2.weight(.bold))
                if case let .steps(done, total) = routine.kind {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(done)")
                            .font(LabFont.number(.largeTitle))
                        Text("из \(total) упражнений")
                            .font(.subheadline.weight(.medium))
                            .opacity(0.85)
                    }
                    LabProgressBar(
                        value: Double(done) / Double(total),
                        tint: LabPalette.onAccent,
                        track: LabPalette.onAccent.opacity(0.25)
                    )
                }
                LabCapsuleButton(title: "Продолжить", kind: .onAccent, fullWidth: true) {}
            }
            .foregroundStyle(LabPalette.onAccent)
            .padding(20)
            .background(LabPalette.accent, in: .rect(cornerRadius: 28, style: .continuous))
        }
    }
#endif
