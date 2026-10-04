import Foundation
@testable import ExercisesTracker
import SwiftData
import Testing

struct SchemaV1Tests {
    /// Kept for the whole test: a context must not outlive its container.
    private let container: ModelContainer

    init() throws {
        container = try ModelContainer(
            for: Schema(versionedSchema: SchemaV1.self),
            migrationPlan: AppMigrationPlan.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    private func makeContext() -> ModelContext {
        ModelContext(container)
    }

    /// Утро → Зарядка → два шага с упражнением + Дневник → шаг-ссылка.
    private func insertMorning(into context: ModelContext) throws -> (DayPart, Exercise) {
        let morning = DayPart(name: "Утро", symbol: "sunrise.fill", startMinute: 300, sortIndex: 0)
        let squats = Exercise(name: "Приседания")
        let workout = Routine(name: "Зарядка", symbol: "figure.cooldown", colorName: "orange", sortIndex: 0)
        let journal = Routine(name: "Дневник", symbol: "book.closed.fill", colorName: "plum", sortIndex: 1)
        context.insert(morning)
        context.insert(squats)
        morning.routines = [workout, journal]
        workout.steps = [
            try Step(sortIndex: 0, config: .exercise(ExerciseStep(sets: 3, target: .reps(15))), exercise: squats),
            try Step(sortIndex: 1, config: .check(CheckStep(title: "Растяжка"))),
        ]
        journal.steps = [
            try Step(sortIndex: 0, config: .link(LinkStep(title: "Запись", url: testURL("journal://")))),
        ]
        try context.save()
        return (morning, squats)
    }

    @Test func deletingDayPartCascadesToRoutinesAndSteps() throws {
        let context = makeContext()
        let (morning, _) = try insertMorning(into: context)
        #expect(try context.fetchCount(FetchDescriptor<Routine>()) == 2)
        #expect(try context.fetchCount(FetchDescriptor<Step>()) == 3)

        context.delete(morning)
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<DayPart>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Routine>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Step>()) == 0)
    }

    @Test func deletingRoutineKeepsLibraryExercise() throws {
        let context = makeContext()
        let (morning, squats) = try insertMorning(into: context)
        let workout = try #require(morning.routines.first { $0.name == "Зарядка" })

        context.delete(workout)
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<Step>()) == 1)
        let exercises = try context.fetch(FetchDescriptor<Exercise>())
        #expect(exercises.map(\.id) == [squats.id])
    }

    /// The step keeps its settings; the UI has to handle an exercise step without an exercise.
    @Test func deletingExerciseKeepsStepWithoutExercise() throws {
        let context = makeContext()
        let (_, squats) = try insertMorning(into: context)
        let stepID = try #require(
            context.fetch(FetchDescriptor<Step>()).first { $0.exercise?.id == squats.id }?.id
        )

        context.delete(squats)
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<Step>()) == 3)
        let step = try #require(context.fetch(FetchDescriptor<Step>(predicate: #Predicate { $0.id == stepID })).first)
        #expect(step.exercise == nil)
        #expect(step.kindRaw == "exercise")
    }

    @Test func stepStoresKindAndDecodesConfig() throws {
        let config = StepConfig.exercise(ExerciseStep(sets: 3, target: .duration(seconds: 30), restSeconds: 20))
        let step = try Step(sortIndex: 0, config: config)
        #expect(step.kindRaw == "exercise")
        #expect(step.config == config)
    }

    @Test func setConfigKeepsKindInSync() throws {
        let step = try Step(sortIndex: 0, config: .check(CheckStep(title: "Витамины")))
        try step.setConfig(.link(LinkStep(title: "Урок", url: testURL("duolingo://"))))
        #expect(step.kindRaw == "link")
        #expect(step.config?.kind == "link")
    }

    @Test func routineWeekdaysMapToRawValue() {
        let routine = Routine(name: "Зарядка", symbol: "figure.cooldown", colorName: "orange", sortIndex: 0)
        #expect(routine.weekdays == .everyDay)
        routine.weekdays = .workdays
        #expect(routine.weekdaysRaw == Weekdays.workdays.rawValue)
    }
}
