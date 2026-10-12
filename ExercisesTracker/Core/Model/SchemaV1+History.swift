import Foundation
import SwiftData

extension SchemaV1 {
    /// One pass through a routine on a given day. Keeps a snapshot of the plan, so editing or deleting
    /// the template later does not change what was done.
    @Model
    final class RoutineRun {
        var id: UUID
        /// `DayKey` of the day it was started on.
        var dayKey: Int
        /// The template it came from; the template may be gone by now.
        var routineID: UUID
        /// Snapshot of the routine name.
        var routineName: String
        /// The part of the day the routine belonged to, if any.
        var dayPartID: UUID?
        var startedAt: Date
        var completedAt: Date?
        @Relationship(deleteRule: .cascade, inverse: \StepResult.run)
        var results: [StepResult]

        init(
            id: UUID = UUID(),
            dayKey: Int,
            routineID: UUID,
            routineName: String,
            dayPartID: UUID?,
            startedAt: Date
        ) {
            self.id = id
            self.dayKey = dayKey
            self.routineID = routineID
            self.routineName = routineName
            self.dayPartID = dayPartID
            self.startedAt = startedAt
            results = []
        }

        /// Starts a run of `routine`: one result per step, in step order, with a copy of each step's plan.
        /// Steps whose settings cannot be read (a kind from a newer app version) are left out:
        /// they could never be completed and would keep the run unfinished forever.
        static func start(_ routine: Routine, at date: Date, calendar: Calendar) -> RoutineRun {
            let run = RoutineRun(
                dayKey: DayKey.of(date, in: calendar),
                routineID: routine.id,
                routineName: routine.name,
                dayPartID: routine.dayPart?.id,
                startedAt: date
            )
            run.results = routine.steps
                .filter { $0.config != nil }
                .sorted { $0.sortIndex < $1.sortIndex }
                .enumerated()
                .map { index, step in StepResult(snapshotOf: step, sortIndex: index) }
            return run
        }

        /// Results in step order.
        var orderedResults: [StepResult] {
            results.sorted { $0.sortIndex < $1.sortIndex }
        }

        /// Every step has a result that completes its plan.
        var isComplete: Bool {
            !results.isEmpty && results.allSatisfy(\.isComplete)
        }

        /// Keeps `completedAt` in step with the results: set once the last step is done, cleared on undo.
        /// Called by `StepResult.record`, so screens do not have to.
        func updateCompletion(at date: Date) {
            completedAt = isComplete ? (completedAt ?? date) : nil
        }
    }

    /// What happened to one step in a run: its planned settings at the time and the actual result.
    @Model
    final class StepResult {
        var id: UUID
        /// The template step; it may be gone by now.
        var stepID: UUID
        var sortIndex: Int
        var kindRaw: String
        /// Snapshot of the exercise name or the step title.
        var title: String
        /// Snapshot of the step's `StepConfig`, in the same JSON format; use `plan`.
        var planData: Data
        /// JSON-encoded `StepActual`, `nil` until something is recorded; use `actual`.
        var actualData: Data?
        /// For charts per exercise; `nil` for other kinds or when the exercise was deleted.
        var exercise: Exercise?
        var completedAt: Date?
        var run: RoutineRun?

        init(
            id: UUID = UUID(),
            stepID: UUID,
            sortIndex: Int,
            kindRaw: String,
            title: String,
            planData: Data,
            exercise: Exercise? = nil
        ) {
            self.id = id
            self.stepID = stepID
            self.sortIndex = sortIndex
            self.kindRaw = kindRaw
            self.title = title
            self.planData = planData
            self.exercise = exercise
        }

        /// A copy of the step as it is now. The bytes of the plan are copied, not referenced.
        convenience init(snapshotOf step: Step, sortIndex: Int) {
            self.init(
                stepID: step.id,
                sortIndex: sortIndex,
                kindRaw: step.kindRaw,
                title: Self.title(of: step),
                planData: step.configData,
                exercise: step.exercise
            )
        }

        /// The plan as it was when the run started.
        var plan: StepConfig? {
            try? StepConfig(data: planData)
        }

        /// What was done; `nil` while nothing is recorded or if the stored data cannot be read.
        var actual: StepActual? {
            actualData.flatMap { try? StepActual(data: $0) }
        }

        /// Records what was done; `nil` takes it back.
        ///
        /// `completedAt` is set the first time the step becomes complete and kept when the fact is edited later,
        /// so correcting reps in the evening does not move a morning workout. The run's completion follows.
        func record(_ actual: StepActual?, at date: Date) throws {
            if let actual, actual.kind != kindRaw {
                throw HistoryError.kindMismatch(expected: kindRaw, got: actual.kind)
            }
            actualData = try actual?.encoded()
            completedAt = isComplete ? (completedAt ?? date) : nil
            run?.updateCompletion(at: date)
        }

        /// «По плану» in one tap.
        func recordAsPlanned(at date: Date) throws {
            guard let plan else { throw HistoryError.unreadablePlan }
            try record(StepActual(asPlannedFor: plan), at: date)
        }

        var isComplete: Bool {
            guard let plan, let actual else { return false }
            return actual.completes(plan)
        }

        private static func title(of step: Step) -> String {
            switch step.config {
            // The library entry may already be deleted; the history row still needs a name.
            case .exercise: step.exercise?.name ?? String(localized: "Упражнение")
            case let .link(link): link.title
            case let .check(check): check.title
            case nil: ""
            }
        }
    }
}

enum HistoryError: Error, Equatable {
    /// A result of another kind than the step, e.g. a checkbox value for an exercise.
    case kindMismatch(expected: String, got: String)
    /// The plan snapshot cannot be decoded, so «по плану» is unknown.
    case unreadablePlan
}
