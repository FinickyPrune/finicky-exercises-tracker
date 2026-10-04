#if DEBUG
    import SwiftUI

    struct LabTodayView: View {
        let style: LabStyle
        private let dayParts = LabDemo.dayParts

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: style.sectionSpacing) {
                    header
                    ForEach(dayParts) { part in
                        section(part)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(LabPalette.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Добавить", systemImage: "plus") {}
                }
            }
        }

        private var header: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text("Суббота, 3 октября")
                    .labCaps()
                    .foregroundStyle(LabPalette.textSecondary)
                Text("Сегодня")
                    .font(style.titleFont)
                    .foregroundStyle(LabPalette.textPrimary)
                if let morning = dayParts.first {
                    let done = Text("\(morning.doneCount)").font(LabFont.number(.title2))
                    Text("\(done) из \(morning.routines.count) на утро")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(LabPalette.textSecondary)
                }
            }
        }

        private func section(_ part: LabDayPart) -> some View {
            VStack(alignment: .leading, spacing: style.rowSpacing + 4) {
                switch style.dayPartHeader {
                case .section: LabDayPartSection(part: part)
                case .capsule: LabDayPartCapsule(part: part)
                }
                if part.routines.isEmpty {
                    LabEmptySlot(prompt: part.emptyPrompt)
                } else {
                    routines(part.routines)
                }
            }
        }

        @ViewBuilder
        private func routines(_ routines: [LabRoutine]) -> some View {
            switch style.todayLayout {
            case .grid:
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: style.rowSpacing), GridItem(.flexible())],
                    spacing: style.rowSpacing
                ) {
                    ForEach(routines) { routine in
                        link(routine) { LabRoutineTile(routine: routine, style: style) }
                    }
                }
            case .list:
                VStack(spacing: style.rowSpacing) {
                    ForEach(routines) { routine in
                        link(routine) {
                            if routine.isCurrent, style.highlight == .filledCard {
                                LabRoutineHero(routine: routine)
                            } else {
                                LabRoutineRow(routine: routine, style: style)
                            }
                        }
                    }
                }
            }
        }

        @ViewBuilder
        private func link(_ routine: LabRoutine, @ViewBuilder label: () -> some View) -> some View {
            if case .steps = routine.kind {
                NavigationLink {
                    LabWorkoutView(style: style)
                } label: {
                    label()
                }
                .buttonStyle(.plain)
            } else {
                label()
            }
        }
    }

    #Preview("A") {
        NavigationStack { LabTodayView(style: .gentler) }
    }

    #Preview("B") {
        NavigationStack { LabTodayView(style: .tiimo) }
    }

    #Preview("C") {
        NavigationStack { LabTodayView(style: .hybrid) }
    }
#endif
