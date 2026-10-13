@testable import ExercisesTracker
import Foundation
import SwiftData
import Testing

struct SwiftDataRoutineStoreTests {
    /// Kept for the whole test: a context must not outlive its container.
    private let container: ModelContainer
    private let store: SwiftDataRoutineStore
    private let calendar: Calendar
    /// 2 October 2026, 7:40 in Belgrade.
    private let morning: Date

    init() throws {
        container = try AppModelContainer.inMemory()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "Europe/Belgrade"))
        self.calendar = calendar
        // Not `mainContext`: it autosaves, and these tests check what each method saves by itself.
        store = SwiftDataRoutineStore(context: ModelContext(container), calendar: calendar)
        morning = try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: 2, hour: 7, minute: 40)))
    }

    /// How many objects are saved: a separate context sees only what is written to the store.
    private func savedCount<Model: PersistentModel>(of _: Model.Type) throws -> Int {
        try ModelContext(container).fetchCount(FetchDescriptor<Model>())
    }

    private func saved(_ result: StepResult) throws -> StepResult {
        let id = result.id
        return try #require(
            ModelContext(container).fetch(FetchDescriptor<StepResult>(predicate: #Predicate { $0.id == id })).first
        )
    }

    /// Утро → Зарядка (приседания 3 × 15, отметка «Растяжка») и Дневник (ссылка).
    private func insertMorning() throws -> (workout: Routine, journal: Routine) {
        let dayPart = DayPart(name: "Утро", symbol: "sunrise.fill", startMinute: 420, sortIndex: 0)
        let squats = Exercise(name: "Приседания")
        let workout = Routine(name: "Зарядка", symbol: "figure.cooldown", colorName: "orange", sortIndex: 0)
        let journal = Routine(name: "Дневник", symbol: "book.closed.fill", colorName: "plum", sortIndex: 1)
        store.insert(dayPart)
        store.insert(squats)
        dayPart.routines = [workout, journal]
        workout.steps = try [
            Step(sortIndex: 0, config: .exercise(ExerciseStep(sets: 3, target: .reps(15))), exercise: squats),
            Step(sortIndex: 1, config: .check(CheckStep(title: "Растяжка"))),
        ]
        journal.steps = try [Step(sortIndex: 0, config: .link(LinkStep(title: "Запись", url: testURL("moments://"))))]
        try store.save()
        return (workout, journal)
    }

    private func date(day: Int, hour: Int, minute: Int = 0) throws -> Date {
        try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute)))
    }

    // MARK: - Templates

    @Test func dayPartsAreInDisplayOrder() throws {
        for (name, sortIndex) in [("Вечер", 2), ("Утро", 0), ("День", 1)] {
            store.insert(DayPart(name: name, symbol: "sun.max.fill", startMinute: 0, sortIndex: sortIndex))
        }
        try store.save()

        #expect(try store.dayParts().map(\.name) == ["Утро", "День", "Вечер"])
    }

    @Test func exercisesAreSortedByNameIgnoringCase() throws {
        for name in ["Приседания", "планка", "Ягодичный мост", "Выпады"] {
            store.insert(Exercise(name: name))
        }
        try store.save()

        #expect(try store.exercises().map(\.name) == ["Выпады", "планка", "Приседания", "Ягодичный мост"])
    }

    @Test func exercisesIncludeArchivedOnes() throws {
        store.insert(Exercise(name: "Отжимания"))
        store.insert(Exercise(name: "Берпи", isArchived: true))
        try store.save()

        #expect(try store.exercises().map(\.name) == ["Берпи", "Отжимания"])
    }

    @Test func templateChangesAreWrittenOnSave() throws {
        let dayPart = DayPart(name: "Утро", symbol: "sunrise.fill", startMinute: 420, sortIndex: 0)
        store.insert(dayPart)
        dayPart.routines = [Routine(name: "Витамины", symbol: "pills.fill", colorName: "amber", sortIndex: 0)]
        #expect(try savedCount(of: DayPart.self) == 0)

        try store.save()

        #expect(try savedCount(of: DayPart.self) == 1)
        #expect(try savedCount(of: Routine.self) == 1)
    }

    @Test func deletingRoutineTakesStepsAndKeepsExercise() throws {
        let (workout, _) = try insertMorning()

        store.delete(workout)
        try store.save()

        #expect(try store.dayParts().first?.orderedRoutines.map(\.name) == ["Дневник"])
        #expect(try savedCount(of: Step.self) == 1)
        #expect(try store.exercises().map(\.name) == ["Приседания"])
    }

    // MARK: - History

    @Test func startOrResumeRunStartsOncePerDay() throws {
        let (workout, _) = try insertMorning()

        let first = try store.startOrResumeRun(of: workout, at: morning)
        #expect(try savedCount(of: RoutineRun.self) == 1)
        #expect(first.orderedResults.map(\.title) == ["Приседания", "Растяжка"])

        let later = try store.startOrResumeRun(of: workout, at: date(day: 2, hour: 21))
        #expect(later.id == first.id)

        let nextDay = try store.startOrResumeRun(of: workout, at: date(day: 3, hour: 7))
        #expect(nextDay.id != first.id)
        #expect(nextDay.dayKey == 20_261_003)
        #expect(try savedCount(of: RoutineRun.self) == 2)
    }

    /// Midnight in the store's calendar, not in UTC (Belgrade is UTC+2 in October).
    @Test func startOrResumeRunStartsANewRunAfterMidnight() throws {
        let (workout, _) = try insertMorning()

        let evening = try store.startOrResumeRun(of: workout, at: date(day: 2, hour: 23, minute: 59))
        let night = try store.startOrResumeRun(of: workout, at: date(day: 3, hour: 0, minute: 1))

        #expect(night.id != evening.id)
        #expect(evening.dayKey == 20_261_002)
        #expect(night.dayKey == 20_261_003)
    }

    @Test func runsOfADayAreOldestFirstAndOnlyThatDay() throws {
        let (workout, journal) = try insertMorning()
        _ = try store.startOrResumeRun(of: workout, at: date(day: 1, hour: 7))
        let journalRun = try store.startOrResumeRun(of: journal, at: date(day: 2, hour: 9))
        let workoutRun = try store.startOrResumeRun(of: workout, at: date(day: 2, hour: 7))

        let runs = try store.runs(on: date(day: 2, hour: 23, minute: 59))

        #expect(runs.map(\.id) == [workoutRun.id, journalRun.id])
    }

    @Test func recordIsSaved() throws {
        let (workout, _) = try insertMorning()
        let run = try store.startOrResumeRun(of: workout, at: morning)
        let squats = try #require(run.orderedResults.first)

        try store.record(.exercise([.reps(15), .reps(12), .reps(10)]), for: squats, at: morning)

        #expect(try saved(squats).actual == .exercise([.reps(15), .reps(12), .reps(10)]))
        #expect(try saved(squats).completedAt == morning)

        try store.record(nil, for: squats, at: morning)

        #expect(try saved(squats).actual == nil)
        #expect(try saved(squats).completedAt == nil)
    }

    @Test func recordAsPlannedCompletesTheRunAndSaves() throws {
        let (workout, _) = try insertMorning()
        let run = try store.startOrResumeRun(of: workout, at: morning)

        for result in run.orderedResults {
            try store.recordAsPlanned(result, at: morning)
        }

        let runID = run.id
        let savedRun = try #require(
            ModelContext(container).fetch(FetchDescriptor<RoutineRun>(predicate: #Predicate { $0.id == runID })).first
        )
        #expect(savedRun.completedAt == morning)
        #expect(savedRun.isComplete)
    }

    @Test func recordOfAnotherKindThrowsAndSavesNothing() throws {
        let (workout, _) = try insertMorning()
        let run = try store.startOrResumeRun(of: workout, at: morning)
        let squats = try #require(run.orderedResults.first)

        #expect(throws: HistoryError.kindMismatch(expected: "exercise", got: "check")) {
            try store.record(.check(true), for: squats, at: morning)
        }
        #expect(try saved(squats).actualData == nil)
    }
}
