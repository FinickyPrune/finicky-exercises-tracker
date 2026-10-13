#if DEBUG
    import DesignSystem
    import Foundation
    import SwiftData

    /// «My morning» from the 0.1 prototype. Debug builds and previews use it until the editor (F4) exists.
    ///
    /// Morning from 7:00: Workout on workdays (six exercises, the plank is timed), Duolingo, Journal, Vitamins.
    /// Day is empty, Evening has Reading. Names are saved in the language of `locale`: from then on they are
    /// ordinary data, which the editor can rename.
    enum DemoData {
        /// Fills a store with nothing in it: the first launch of a Debug build. A store with any template
        /// or history is left alone; one emptied completely gets the demo again on the next launch.
        static func insertIfEmpty(into context: ModelContext, locale: Locale = .current) throws {
            let isEmpty = try context.fetchCount(FetchDescriptor<DayPart>()) == 0
                && context.fetchCount(FetchDescriptor<Routine>()) == 0
                && context.fetchCount(FetchDescriptor<Exercise>()) == 0
                && context.fetchCount(FetchDescriptor<RoutineRun>()) == 0
            if isEmpty {
                try insert(into: context, locale: locale)
            }
        }

        /// Inserts the demo templates and saves.
        static func insert(into context: ModelContext, locale: Locale = .current) throws {
            let text = { (resource: LocalizedStringResource) in resource.string(in: locale) }
            let morning = DayPart(name: text(.demoMorning), symbol: "sunrise.fill", startMinute: 7 * 60, sortIndex: 0)
            let day = DayPart(name: text(.demoDay), symbol: "sun.max.fill", startMinute: 12 * 60, sortIndex: 1)
            let evening = DayPart(
                name: text(.demoEvening), symbol: "moon.stars.fill", startMinute: 20 * 60, sortIndex: 2
            )
            for dayPart in [morning, day, evening] {
                context.insert(dayPart)
            }

            morning.routines = try [
                workout(into: context, text: text),
                routine(text(.demoDuolingo), symbol: "bird.fill", tint: .sage, sortIndex: 1, step: .link(
                    LinkStep(title: text(.demoDuolingoLesson), url: url("duolingo://"))
                )),
                // moments:// is the scheme reported for Apple Journal, not documented by Apple.
                // Journal is not on the simulator: unverified until tried on a device.
                routine(text(.demoJournal), symbol: "book.closed.fill", tint: .plum, sortIndex: 2, step: .link(
                    LinkStep(title: text(.demoJournalEntry), url: url("moments://"))
                )),
                routine(text(.demoVitamins), symbol: "pills.fill", tint: .amber, sortIndex: 3, step: .check(
                    CheckStep(title: text(.demoVitamins))
                )),
            ]
            evening.routines = try [
                routine(text(.demoReading), symbol: "books.vertical.fill", tint: .coral, sortIndex: 0, step: .check(
                    CheckStep(title: text(.demoReading))
                )),
            ]
            try context.save()
        }

        // MARK: - Workout

        private struct DemoExercise {
            let name: LocalizedStringResource
            let notes: LocalizedStringResource
            let plan: ExerciseStep
            /// Rendered once per launch: previews and tests insert the demo many times.
            let photo: Data?

            /// `symbol` and `tint` make the stand-in photo.
            init(
                name: LocalizedStringResource, notes: LocalizedStringResource, symbol: String, tint: RoutineTint,
                plan: ExerciseStep
            ) {
                self.name = name
                self.notes = notes
                self.plan = plan
                photo = DemoPhoto.jpeg(symbol: symbol, tint: tint)
            }
        }

        private static let exercises = [
            DemoExercise(
                name: .demoSquats, notes: .demoSquatsNotes, symbol: "figure.strengthtraining.functional",
                tint: .orange, plan: ExerciseStep(sets: 3, target: .reps(15))
            ),
            DemoExercise(
                name: .demoPushUps, notes: .demoPushUpsNotes, symbol: "figure.strengthtraining.traditional",
                tint: .coral, plan: ExerciseStep(sets: 3, target: .reps(10))
            ),
            DemoExercise(
                name: .demoPlank, notes: .demoPlankNotes, symbol: "figure.core.training", tint: .amber,
                plan: ExerciseStep(sets: 3, target: .duration(seconds: 30), restSeconds: 20)
            ),
            DemoExercise(
                name: .demoLunges, notes: .demoLungesNotes, symbol: "figure.step.training", tint: .plum,
                plan: ExerciseStep(sets: 3, target: .reps(12))
            ),
            DemoExercise(
                name: .demoGluteBridge, notes: .demoGluteBridgeNotes, symbol: "figure.pilates", tint: .sage,
                plan: ExerciseStep(sets: 3, target: .reps(15))
            ),
            DemoExercise(
                name: .demoStretching, notes: .demoStretchingNotes, symbol: "figure.flexibility", tint: .coral,
                plan: ExerciseStep(sets: 1, target: .duration(seconds: 90))
            ),
        ]

        private static func workout(
            into context: ModelContext, text: (LocalizedStringResource) -> String
        ) throws -> Routine {
            let workout = Routine(
                name: text(.demoWorkout), symbol: "figure.cooldown", colorName: RoutineTint.orange.rawValue,
                weekdays: .workdays, sortIndex: 0
            )
            workout.steps = try exercises.enumerated().map { index, demo in
                let exercise = Exercise(name: text(demo.name), notes: text(demo.notes), photo: demo.photo)
                context.insert(exercise)
                return try Step(sortIndex: index, config: .exercise(demo.plan), exercise: exercise)
            }
            return workout
        }

        // MARK: - Helpers

        /// A routine of one step, done right in the list.
        private static func routine(
            _ name: String, symbol: String, tint: RoutineTint, sortIndex: Int, step: StepConfig
        ) throws -> Routine {
            let routine = Routine(name: name, symbol: symbol, colorName: tint.rawValue, sortIndex: sortIndex)
            routine.steps = try [Step(sortIndex: 0, config: step)]
            return routine
        }

        /// A URL from a literal above.
        private static func url(_ string: String) -> URL {
            guard let url = URL(string: string) else {
                preconditionFailure("Invalid demo URL: \(string)")
            }
            return url
        }
    }
#endif
