#if DEBUG
    import DesignSystem
    import Foundation
    import SwiftData

    /// «Моё утро» from the 0.1 prototype. Debug builds and previews use it until the editor (F4) exists.
    ///
    /// Утро с 7:00: Зарядка on workdays (six exercises, the plank is timed), Duolingo, Дневник, Витамины.
    /// День is empty, Вечер has Чтение.
    enum DemoData {
        /// Fills a store with nothing in it: the first launch of a Debug build. A store with any template
        /// or history is left alone; one emptied completely gets «моё утро» again on the next launch.
        static func insertIfEmpty(into context: ModelContext) throws {
            let isEmpty = try context.fetchCount(FetchDescriptor<DayPart>()) == 0
                && context.fetchCount(FetchDescriptor<Routine>()) == 0
                && context.fetchCount(FetchDescriptor<Exercise>()) == 0
                && context.fetchCount(FetchDescriptor<RoutineRun>()) == 0
            if isEmpty {
                try insert(into: context)
            }
        }

        /// Inserts the demo templates and saves.
        static func insert(into context: ModelContext) throws {
            let morning = DayPart(name: "Утро", symbol: "sunrise.fill", startMinute: 7 * 60, sortIndex: 0)
            let day = DayPart(name: "День", symbol: "sun.max.fill", startMinute: 12 * 60, sortIndex: 1)
            let evening = DayPart(name: "Вечер", symbol: "moon.stars.fill", startMinute: 20 * 60, sortIndex: 2)
            for dayPart in [morning, day, evening] {
                context.insert(dayPart)
            }

            morning.routines = try [
                workout(into: context),
                routine("Duolingo", symbol: "bird.fill", tint: .sage, sortIndex: 1, step: .link(
                    LinkStep(title: "Урок", url: url("duolingo://"))
                )),
                // moments:// is the scheme reported for Apple Journal, not documented by Apple.
                // Journal is not on the simulator: unverified until tried on a device.
                routine("Дневник", symbol: "book.closed.fill", tint: .plum, sortIndex: 2, step: .link(
                    LinkStep(title: "Запись в дневник", url: url("moments://"))
                )),
                routine("Витамины", symbol: "pills.fill", tint: .amber, sortIndex: 3, step: .check(
                    CheckStep(title: "Витамины")
                )),
            ]
            evening.routines = try [
                routine("Чтение", symbol: "books.vertical.fill", tint: .coral, sortIndex: 0, step: .check(
                    CheckStep(title: "Чтение")
                )),
            ]
            try context.save()
        }

        // MARK: - Зарядка

        private struct DemoExercise {
            let name: String
            let notes: String
            let plan: ExerciseStep
            /// Rendered once per launch: previews and tests insert the demo many times.
            let photo: Data?

            /// `symbol` and `tint` make the stand-in photo.
            init(name: String, notes: String, symbol: String, tint: RoutineTint, plan: ExerciseStep) {
                self.name = name
                self.notes = notes
                self.plan = plan
                photo = DemoPhoto.jpeg(symbol: symbol, tint: tint)
            }
        }

        private static let exercises = [
            DemoExercise(
                name: "Приседания", notes: "Стопы на ширине плеч, вес на пятках, спина прямая.",
                symbol: "figure.strengthtraining.functional", tint: .orange,
                plan: ExerciseStep(sets: 3, target: .reps(15))
            ),
            DemoExercise(
                name: "Отжимания", notes: "Тело — одна линия от головы до пяток.",
                symbol: "figure.strengthtraining.traditional", tint: .coral,
                plan: ExerciseStep(sets: 3, target: .reps(10))
            ),
            DemoExercise(
                name: "Планка", notes: "На предплечьях, живот подтянут, поясница не провисает.",
                symbol: "figure.core.training", tint: .amber,
                plan: ExerciseStep(sets: 3, target: .duration(seconds: 30), restSeconds: 20)
            ),
            DemoExercise(
                name: "Выпады", notes: "Шаг вперёд, оба колена под прямым углом, ноги попеременно.",
                symbol: "figure.step.training", tint: .plum,
                plan: ExerciseStep(sets: 3, target: .reps(12))
            ),
            DemoExercise(
                name: "Ягодичный мост", notes: "Лёжа на спине поднять таз и задержаться наверху.",
                symbol: "figure.pilates", tint: .sage,
                plan: ExerciseStep(sets: 3, target: .reps(15))
            ),
            DemoExercise(
                name: "Растяжка", notes: "Спокойно, без рывков: ноги, спина, плечи.",
                symbol: "figure.flexibility", tint: .coral,
                plan: ExerciseStep(sets: 1, target: .duration(seconds: 90))
            ),
        ]

        private static func workout(into context: ModelContext) throws -> Routine {
            let workout = Routine(
                name: "Зарядка", symbol: "figure.cooldown", colorName: RoutineTint.orange.rawValue,
                weekdays: .workdays, sortIndex: 0
            )
            workout.steps = try exercises.enumerated().map { index, demo in
                let exercise = Exercise(name: demo.name, notes: demo.notes, photo: demo.photo)
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
