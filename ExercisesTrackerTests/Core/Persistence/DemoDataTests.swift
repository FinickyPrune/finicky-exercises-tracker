@testable import ExercisesTracker
import Foundation
import SwiftData
import Testing

struct DemoDataTests {
    /// Kept for the whole test: a context must not outlive its container.
    private let container: ModelContainer
    private let context: ModelContext
    private let store: SwiftDataRoutineStore

    init() throws {
        container = try AppModelContainer.inMemory()
        context = ModelContext(container)
        store = SwiftDataRoutineStore(context: context)
    }

    private func routine(_ name: String) throws -> Routine {
        try #require(store.dayParts().flatMap(\.routines).first { $0.name == name })
    }

    @Test func morningHasTheRoutinesInOrder() throws {
        try DemoData.insert(into: context)

        let dayParts = try store.dayParts()
        #expect(dayParts.map(\.name) == ["Утро", "День", "Вечер"])
        #expect(dayParts.map(\.startMinute) == [420, 720, 1200])
        #expect(dayParts.map { $0.orderedRoutines.map(\.name) } == [
            ["Зарядка", "Duolingo", "Дневник", "Витамины"], [], ["Чтение"],
        ])
    }

    @Test func workoutIsSixExercisesOnWorkdaysWithATimedOne() throws {
        try DemoData.insert(into: context)
        let workout = try routine("Зарядка")

        #expect(workout.weekdays == .workdays)
        let plans = workout.orderedSteps.compactMap { step -> ExerciseStep? in
            guard case let .exercise(plan) = step.config else { return nil }
            return plan
        }
        #expect(plans.count == 6)
        #expect(workout.orderedSteps.map { $0.exercise?.name } == [
            "Приседания", "Отжимания", "Планка", "Выпады", "Ягодичный мост", "Растяжка",
        ])
        #expect(plans.contains { $0.target == .duration(seconds: 30) && $0.restSeconds == 20 })
    }

    @Test func everyExerciseHasAPhotoAndNotes() throws {
        try DemoData.insert(into: context)

        let exercises = try store.exercises()
        #expect(exercises.count == 6)
        for exercise in exercises {
            #expect(exercise.photo?.isEmpty == false, "\(exercise.name) has no photo")
            #expect(!exercise.notes.isEmpty, "\(exercise.name) has no notes")
        }
    }

    @Test func simpleRoutinesAreOneLinkOrCheck() throws {
        try DemoData.insert(into: context)

        let configs = try ["Duolingo", "Дневник", "Витамины", "Чтение"].map { try routine($0).steps.map(\.config) }
        #expect(configs == [
            [.link(LinkStep(title: "Урок", url: testURL("duolingo://")))],
            [.link(LinkStep(title: "Запись в дневник", url: testURL("moments://")))],
            [.check(CheckStep(title: "Витамины"))],
            [.check(CheckStep(title: "Чтение"))],
        ])
        for name in ["Duolingo", "Дневник", "Витамины", "Чтение"] {
            #expect(try routine(name).weekdays == .everyDay)
        }
    }

    /// Every demo routine can be started and finished «по плану», so the data is usable as it is.
    @Test func everyRoutineCanBeDoneAsPlanned() throws {
        try DemoData.insert(into: context)
        let now = Date.now

        for routine in try store.dayParts().flatMap(\.orderedRoutines) {
            let run = try store.startOrResumeRun(of: routine, at: now)
            for result in run.orderedResults {
                try store.recordAsPlanned(result, at: now)
            }
            #expect(run.results.count == routine.steps.count, "\(routine.name) lost a step")
            #expect(run.isComplete, "\(routine.name) is not complete")
        }
    }

    @Test func insertIfEmptyFillsAnEmptyStoreOnce() throws {
        try DemoData.insertIfEmpty(into: context)
        try DemoData.insertIfEmpty(into: context)

        #expect(try context.fetchCount(FetchDescriptor<DayPart>()) == 3)
        #expect(try context.fetchCount(FetchDescriptor<Exercise>()) == 6)
    }

    /// The user deleted every template but has history: the demo must not come back.
    @Test func insertIfEmptyLeavesStoreWithHistoryAlone() throws {
        try DemoData.insert(into: context)
        let workout = try routine("Зарядка")
        _ = try store.startOrResumeRun(of: workout, at: .now)
        for dayPart in try store.dayParts() {
            store.delete(dayPart)
        }
        for exercise in try store.exercises() {
            store.delete(exercise)
        }
        try store.save()

        try DemoData.insertIfEmpty(into: context)

        #expect(try context.fetchCount(FetchDescriptor<DayPart>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<RoutineRun>()) == 1)
    }
}
