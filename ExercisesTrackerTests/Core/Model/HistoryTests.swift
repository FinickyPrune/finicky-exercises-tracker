@testable import ExercisesTracker
import Foundation
import SwiftData
import Testing

struct HistoryTests {
    /// Kept for the whole test: a context must not outlive its container.
    private let container: ModelContainer
    private let context: ModelContext
    private let calendar: Calendar
    private let morning: Date

    init() throws {
        container = try ModelContainer(
            for: Schema(versionedSchema: SchemaV1.self),
            migrationPlan: AppMigrationPlan.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = ModelContext(container)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "Europe/Belgrade"))
        self.calendar = calendar
        morning = try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: 2, hour: 7, minute: 40)))
    }

    /// Утро → Зарядка: приседания 3 × 15, планка 2 × 0:30, отметка «Растяжка».
    private func insertWorkout() throws -> (Routine, Exercise) {
        let dayPart = DayPart(name: "Утро", symbol: "sunrise.fill", startMinute: 300, sortIndex: 0)
        let squats = Exercise(name: "Приседания")
        let plank = Exercise(name: "Планка")
        let workout = Routine(name: "Зарядка", symbol: "figure.cooldown", colorName: "orange", sortIndex: 0)
        context.insert(dayPart)
        context.insert(squats)
        context.insert(plank)
        dayPart.routines = [workout]
        // Inserted out of order on purpose: the run must follow sortIndex.
        workout.steps = try [
            Step(sortIndex: 2, config: .check(CheckStep(title: "Растяжка"))),
            Step(sortIndex: 0, config: .exercise(ExerciseStep(sets: 3, target: .reps(15))), exercise: squats),
            Step(
                sortIndex: 1, config: .exercise(ExerciseStep(sets: 2, target: .duration(seconds: 30))), exercise: plank
            ),
        ]
        try context.save()
        return (workout, squats)
    }

    private func startRun(of routine: Routine) throws -> RoutineRun {
        let run = RoutineRun.start(routine, at: morning, calendar: calendar)
        context.insert(run)
        try context.save()
        return run
    }

    @Test func startCopiesThePlan() throws {
        let (workout, squats) = try insertWorkout()
        let run = try startRun(of: workout)

        #expect(run.dayKey == 20_261_002)
        #expect(run.routineID == workout.id)
        #expect(run.routineName == "Зарядка")
        #expect(run.dayPartID == workout.dayPart?.id)
        #expect(run.completedAt == nil)
        let results = run.orderedResults
        #expect(results.map(\.title) == ["Приседания", "Планка", "Растяжка"])
        #expect(results.map(\.kindRaw) == ["exercise", "exercise", "check"])
        #expect(results.map(\.sortIndex) == [0, 1, 2])
        #expect(results[0].plan == .exercise(ExerciseStep(sets: 3, target: .reps(15))))
        #expect(results[0].exercise?.id == squats.id)
        #expect(results.allSatisfy { $0.actual == nil && !$0.isComplete })
    }

    @Test func editingTemplateDoesNotChangeHistory() throws {
        let (workout, squats) = try insertWorkout()
        let run = try startRun(of: workout)
        let squatStep = try #require(workout.steps.first { $0.sortIndex == 0 })

        try squatStep.setConfig(.exercise(ExerciseStep(sets: 3, target: .reps(20))))
        squats.name = "Глубокие приседания"
        workout.name = "Утренняя зарядка"
        try context.save()

        #expect(run.routineName == "Зарядка")
        let result = try #require(run.orderedResults.first)
        #expect(result.title == "Приседания")
        #expect(result.plan == .exercise(ExerciseStep(sets: 3, target: .reps(15))))
    }

    @Test func deletingTemplateKeepsHistory() throws {
        let (workout, squats) = try insertWorkout()
        let run = try startRun(of: workout)
        let runID = run.id

        context.delete(workout)
        context.delete(squats)
        try context.save()

        let stored = try #require(
            context.fetch(FetchDescriptor<RoutineRun>(predicate: #Predicate { $0.id == runID })).first
        )
        #expect(stored.results.count == 3)
        let squatResult = try #require(stored.orderedResults.first)
        #expect(squatResult.title == "Приседания")
        #expect(squatResult.exercise == nil)
        #expect(squatResult.plan == .exercise(ExerciseStep(sets: 3, target: .reps(15))))
    }

    @Test func recordingAsPlannedCompletesTheRun() throws {
        let (workout, _) = try insertWorkout()
        let run = try startRun(of: workout)

        for result in run.orderedResults {
            try result.recordAsPlanned(at: morning)
        }

        #expect(run.orderedResults.allSatisfy { $0.isComplete && $0.completedAt == morning })
        #expect(run.isComplete)
    }

    @Test func editingFactKeepsStepDoneButUndoClearsIt() throws {
        let (workout, _) = try insertWorkout()
        let run = try startRun(of: workout)
        let squats = try #require(run.orderedResults.first)

        try squats.record(.exercise([.reps(15), .reps(12), .reps(10)]), at: morning)
        #expect(squats.isComplete)
        #expect(squats.actual == .exercise([.reps(15), .reps(12), .reps(10)]))

        try squats.record(nil, at: morning)
        #expect(!squats.isComplete)
        #expect(squats.completedAt == nil)
        #expect(!run.isComplete)
    }

    @Test func runCompletionFollowsItsSteps() throws {
        let (workout, _) = try insertWorkout()
        let run = try startRun(of: workout)
        let later = morning.addingTimeInterval(600)

        for result in run.orderedResults {
            try result.recordAsPlanned(at: morning)
        }
        #expect(run.completedAt == morning)

        try run.orderedResults[0].record(.exercise([.reps(15), .reps(12), .reps(10)]), at: later)
        #expect(run.completedAt == morning)

        try run.orderedResults[2].record(nil, at: later)
        #expect(run.completedAt == nil)
    }

    /// Correcting the fact in the evening keeps the morning time.
    @Test func editingFactKeepsOriginalCompletionTime() throws {
        let (workout, _) = try insertWorkout()
        let run = try startRun(of: workout)
        let squats = try #require(run.orderedResults.first)
        let evening = morning.addingTimeInterval(12 * 3600)

        try squats.recordAsPlanned(at: morning)
        try squats.record(.exercise([.reps(15), .reps(12), .reps(10)]), at: evening)

        #expect(squats.completedAt == morning)
    }

    @Test func resultOfAnotherKindIsRejected() throws {
        let (workout, _) = try insertWorkout()
        let run = try startRun(of: workout)
        let squats = try #require(run.orderedResults.first)

        #expect(throws: HistoryError.kindMismatch(expected: "exercise", got: "check")) {
            try squats.record(.check(true), at: morning)
        }
        #expect(squats.actualData == nil)
    }

    @Test func exerciseStepWithoutExerciseStillHasATitle() throws {
        let (workout, squats) = try insertWorkout()
        context.delete(squats)
        try context.save()

        let run = try startRun(of: workout)

        #expect(run.orderedResults.first?.title == "Упражнение")
    }

    @Test func unreadableStepIsLeftOutOfTheRun() throws {
        let (workout, _) = try insertWorkout()
        let broken = try #require(workout.steps.first { $0.sortIndex == 2 })
        broken.configData = Data(#"{"type":"strength","settings":{}}"#.utf8)
        try context.save()

        let run = try startRun(of: workout)

        #expect(run.orderedResults.map(\.title) == ["Приседания", "Планка"])
    }

    @Test func emptyRoutineRunIsNotComplete() throws {
        let routine = Routine(name: "Пусто", symbol: "circle", colorName: "sand", sortIndex: 0)
        context.insert(routine)
        let run = try startRun(of: routine)
        #expect(!run.isComplete)
    }

    @Test func corruptActualReadsAsNothing() throws {
        let (workout, _) = try insertWorkout()
        let run = try startRun(of: workout)
        let squats = try #require(run.orderedResults.first)

        squats.actualData = Data("garbage".utf8)

        #expect(squats.actual == nil)
        #expect(!squats.isComplete)
    }

    @Test func deletingRunDeletesItsResults() throws {
        let (workout, _) = try insertWorkout()
        let run = try startRun(of: workout)

        context.delete(run)
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<StepResult>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Step>()) == 3)
    }
}
